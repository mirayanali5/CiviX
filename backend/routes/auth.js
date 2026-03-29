const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const supabase = require('../config/supabase');

// Citizen Signup
router.post('/signup', async (req, res) => {
  try {
    const { name, email, password, account_type: at, accountType } = req.body || {};
    const account_type = at ?? accountType ?? 'private';

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    if (account_type !== 'private' && account_type !== 'public') {
      return res.status(400).json({ error: 'Account type must be private or public' });
    }

    const emailNorm = (email || '').toString().trim().toLowerCase();
    if (!emailNorm) {
      return res.status(400).json({ error: 'Valid email is required' });
    }

    // Check if user exists (case-insensitive email)
    const existingUser = await pool.query(
      'SELECT id FROM profiles WHERE LOWER(TRIM(email)) = $1',
      [emailNorm]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Generate UUID for user ID (matching Supabase schema)
    const { v4: uuidv4 } = require('uuid');
    const userId = uuidv4();

    // Insert profile with plain text password (store email as provided, normalized for lookup)
    const result = await pool.query(
      `INSERT INTO profiles (id, full_name, email, role, account_type, password)
       VALUES ($1::uuid, $2, $3, 'citizen', $4, $5)
       RETURNING id, full_name as name, email, role, account_type, created_at`,
      [userId, name, emailNorm, account_type, password]
    );

    const user = result.rows[0];

    // Generate JWT
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'User created successfully',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        account_type: user.account_type
      },
      token
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Citizen Login
router.post('/login', async (req, res) => {
  try {
    const email = (req.body.email || '').toString().trim().toLowerCase();
    const password = (req.body.password || '').toString().trim();

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Case-insensitive email lookup; allow citizen or null role (exclude authority)
    const result = await pool.query(
      `SELECT * FROM profiles WHERE LOWER(TRIM(email)) = $1 AND (role IS NULL OR role <> 'authority')`,
      [email]
    );

    if (result.rows.length === 0) {
      console.log('Citizen login: no profile found for email:', email);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = result.rows[0];
    const storedPassword = user.password != null ? String(user.password).trim() : '';

    // Check password (plain text comparison - stored in profiles.password)
    if (storedPassword === '') {
      console.log('Citizen login: profile has no password for email:', email);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    if (storedPassword !== password) {
      console.log('Citizen login: password mismatch for email:', email);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    console.log('Citizen login success:', user.id, user.email);

    // Generate JWT
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        name: user.full_name || user.name,
        email: user.email,
        role: user.role,
        account_type: user.account_type
      },
      token
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * Citizen Login with Google (Supabase Auth)
 *
 * This route is intended for clients that already have a valid Supabase
 * access token (e.g. obtained via `supabase.auth.signInWithOAuth(OAuthProvider.google)`).
 *
 * Flow (high level):
 * - Flutter app uses Supabase Auth (Google provider) to sign in and obtains a JWT access token.
 * - The app sends a POST request to /auth/login/google with `Authorization: Bearer <supabase_jwt>`.
 * - This route verifies the token (via authenticateToken), ensures the account is a citizen,
 *   upserts a row in the `profiles` table (if missing), and returns a response compatible
 *   with the existing email/password login (token + user object).
 *
 * IMPORTANT:
 * - JWT_SECRET or SUPABASE_JWT_SECRET in the backend .env MUST match the JWT secret
 *   configured in Supabase Auth so that authenticateToken can verify Supabase tokens.
 * - Google login is only allowed for citizen accounts. Authority accounts must continue
 *   to use the existing /auth/authority/login route with email/password.
 */
router.post('/login/google', authenticateToken, async (req, res) => {
  try {
    // authenticateToken sets req.user for a valid JWT.
    // For Supabase tokens, req.user will be derived from decoded.sub / decoded.email.
    const authUser = req.user;

    if (!authUser || !authUser.id) {
      return res.status(401).json({ error: 'Not authenticated' });
    }

    // Google / Supabase Auth is only for citizens.
    // We will always enforce role = 'citizen' in profiles for this route.

    // First, check if a profile already exists for this Supabase user id
    const existing = await pool.query(
      'SELECT id, full_name, email, role, department, account_type, created_at FROM profiles WHERE id = $1::uuid',
      [authUser.id]
    );

    let profile;

    if (existing.rows.length > 0) {
      profile = existing.rows[0];

      // If this profile was somehow marked as authority, block Google login for safety
      if (profile.role === 'authority') {
        return res.status(403).json({
          error: 'Google login is only available for citizen accounts',
        });
      }

      // Ensure role is citizen for Google-based logins
      if (profile.role !== 'citizen') {
        const updated = await pool.query(
          `UPDATE profiles
           SET role = 'citizen'
           WHERE id = $1::uuid
           RETURNING id, full_name, email, role, department, account_type, created_at`,
          [authUser.id]
        );
        profile = updated.rows[0];
      }
    } else {
      // No profile row yet – create one from Supabase Auth user metadata
      if (!supabase) {
        return res.status(500).json({
          error: 'Supabase is not configured on the server. Google login cannot be used right now.',
        });
      }

      const { data, error } = await supabase.auth.admin.getUserById(authUser.id);

      if (error || !data || !data.user) {
        console.error('Supabase admin getUserById error:', error || 'No user in data');
        return res.status(500).json({
          error: 'Could not fetch user details from Supabase for Google login',
        });
      }

      const supaUser = data.user;
      const email = (supaUser.email || '').toString().trim().toLowerCase();
      const fullName =
        (supaUser.user_metadata &&
          (supaUser.user_metadata.full_name ||
            supaUser.user_metadata.name ||
            supaUser.user_metadata.display_name)) ||
        email.split('@')[0] ||
        null;

      // Default account_type for Google-based citizen accounts:
      // private unless user explicitly chooses otherwise later.
      const accountType = 'private';

      const created = await pool.query(
        `INSERT INTO profiles (id, email, full_name, account_type, role, department, password)
         VALUES ($1::uuid, $2, $3, $4, 'citizen', NULL, NULL)
         RETURNING id, full_name, email, role, department, account_type, created_at`,
        [supaUser.id, email || null, fullName, accountType]
      );

      profile = created.rows[0];
    }

    // Reuse the Supabase JWT that the client already has.
    // For consistency with other login responses we still return a `token` field.
    const authHeader = req.headers['authorization'] || '';
    const token =
      typeof authHeader === 'string' && authHeader.startsWith('Bearer ')
        ? authHeader.split(' ')[1]
        : null;

    if (!token) {
      return res.status(500).json({
        error: 'Missing bearer token in request',
      });
    }

    return res.json({
      message: 'Login successful',
      user: {
        id: profile.id,
        name: profile.full_name,
        email: profile.email,
        role: profile.role,
        department: profile.department,
        account_type: profile.account_type,
        created_at: profile.created_at,
      },
      token,
    });
  } catch (error) {
    console.error('Google login error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Authority Login
router.post('/authority/login', async (req, res) => {
  try {
    const email = (req.body.email || '').toString().trim().toLowerCase();
    const password = (req.body.password || '').toString().trim();

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Case-insensitive email, role must be 'authority'
    const result = await pool.query(
      'SELECT * FROM profiles WHERE LOWER(TRIM(email)) = $1 AND role = $2',
      [email, 'authority']
    );

    if (result.rows.length === 0) {
      console.log('Authority login: no authority profile for email:', email);
      return res.status(401).json({ error: 'Invalid email or password, or not an authority account' });
    }

    const user = result.rows[0];
    const storedPassword = user.password != null ? String(user.password).trim() : '';

    // Check if password exists (plain text comparison)
    if (storedPassword === '') {
      console.error('Authority user missing password. User needs to be created with password.');
      return res.status(500).json({ 
        error: 'Account not configured. Please contact administrator.' 
      });
    }

    // Check password (plain text comparison)
    if (storedPassword !== password) {
      console.log('Authority login: password mismatch for email:', email);
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    console.log('Authority login success:', user.id, user.email, 'department:', user.department);

    // Generate JWT (include department from profiles table)
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email, 
        role: user.role, 
        department: user.department // Now available from profiles table
      },
      process.env.JWT_SECRET || process.env.SUPABASE_JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        name: user.full_name || user.name,
        email: user.email,
        role: user.role,
        department: user.department,
        account_type: user.account_type
      },
      token
    });
  } catch (error) {
    console.error('Authority login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get current user
router.get('/me', authenticateToken, async (req, res) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Not authenticated' });
  }

  try {
    const result = await pool.query(
      'SELECT id, full_name as name, email, role, department, account_type, created_at FROM profiles WHERE id = $1::uuid',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user: result.rows[0] });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
