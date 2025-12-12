const jwt = require('jsonwebtoken');
const pool = require('../config/database');

/**
 * Middleware to verify JWT token
 * Supports both Supabase JWT tokens and custom JWT tokens
 * Fetches department from profiles table if not in token (for authority users)
 */
async function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    // Allow anonymous access (guest_id will be used)
    req.user = null;
    return next();
  }

  // Use JWT_SECRET (should match Supabase JWT Secret if using Supabase Auth)
  const jwtSecret = process.env.JWT_SECRET || process.env.SUPABASE_JWT_SECRET;
  
  if (!jwtSecret) {
    console.warn('⚠️  JWT_SECRET not configured');
    return res.status(500).json({ error: 'Server configuration error' });
  }

  try {
    const decoded = jwt.verify(token, jwtSecret);

    // Supabase JWT tokens have different structure
    // Extract user info from token payload
    let userInfo;
    if (decoded.sub) {
      // Supabase token format: { sub: user_id, email: ..., role: ... }
      userInfo = {
        id: decoded.sub,
        email: decoded.email,
        role: decoded.role || decoded.user_role || 'citizen',
        department: decoded.department
      };
    } else {
      // Custom token format: { id: ..., email: ..., role: ..., department: ... }
      userInfo = decoded;
    }

    // If department is not in token, fetch from profiles table (for authority users)
    if (!userInfo.department && userInfo.role === 'authority') {
      try {
        const profileResult = await pool.query(
          'SELECT department FROM profiles WHERE id = $1::uuid',
          [userInfo.id]
        );
        if (profileResult.rows.length > 0) {
          userInfo.department = profileResult.rows[0].department;
        }
      } catch (error) {
        console.warn('Could not fetch department from profiles:', error.message);
      }
    }

    req.user = userInfo;
    next();
  } catch (err) {
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
}

/**
 * Middleware to require authentication
 */
function requireAuth(req, res, next) {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  next();
}

/**
 * Middleware to require authority role
 */
function requireAuthority(req, res, next) {
  if (!req.user || req.user.role !== 'authority') {
    return res.status(403).json({ error: 'Authority access required' });
  }
  next();
}

module.exports = { authenticateToken, requireAuth, requireAuthority };
