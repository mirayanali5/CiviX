const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// Citizen Signup
router.post('/signup', async (req, res) => {
  try {
    const { name, email, password, account_type = 'private' } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    if (account_type !== 'private' && account_type !== 'public') {
      return res.status(400).json({ error: 'Account type must be private or public' });
    }

    // Check if user exists in profiles
    const existingUser = await pool.query(
      'SELECT id FROM profiles WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate UUID for user ID (matching Supabase schema)
    const { v4: uuidv4 } = require('uuid');
    const userId = uuidv4();

    // Insert profile (note: if using Supabase Auth, profile should be created via trigger)
    // For custom auth, you may need a separate auth_users table or add password_hash to profiles
    const result = await pool.query(
      `INSERT INTO profiles (id, full_name, email, role, account_type)
       VALUES ($1::uuid, $2, $3, 'citizen', $4)
       RETURNING id, full_name as name, email, role, account_type, created_at`,
      [userId, name, email, account_type]
    );
    
    // Store password hash separately (you may want to create an auth_users table)
    // For now, we'll skip password storage if using Supabase Auth

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
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Note: If using Supabase Auth, authentication happens on frontend
    // This is for custom JWT auth. You may need to store passwords separately
    const result = await pool.query(
      'SELECT * FROM profiles WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // TODO: If using custom auth, you need to store password_hash somewhere
    // For now, this assumes you're using Supabase Auth on frontend
    // If using custom auth, uncomment and store password_hash:
    // const validPassword = await bcrypt.compare(password, user.password_hash);
    // if (!validPassword) {
    //   return res.status(401).json({ error: 'Invalid credentials' });
    // }

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
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const result = await pool.query(
      'SELECT * FROM profiles WHERE email = $1 AND role = $2',
      [email, 'authority']
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials or not an authority user' });
    }

    const user = result.rows[0];

    // Check password
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role, department: user.department },
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
      'SELECT id, full_name as name, email, role, account_type, created_at FROM profiles WHERE id = $1::uuid',
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
