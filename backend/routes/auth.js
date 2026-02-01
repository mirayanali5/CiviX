const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

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
