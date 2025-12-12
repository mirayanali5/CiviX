const jwt = require('jsonwebtoken');

/**
 * Middleware to verify JWT token
 * Supports both Supabase JWT tokens and custom JWT tokens
 */
function authenticateToken(req, res, next) {
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

  jwt.verify(token, jwtSecret, (err, decoded) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    
    // Supabase JWT tokens have different structure
    // Extract user info from token payload
    if (decoded.sub) {
      // Supabase token format: { sub: user_id, email: ..., role: ... }
      req.user = {
        id: decoded.sub,
        email: decoded.email,
        role: decoded.role || decoded.user_role || 'citizen'
      };
    } else {
      // Custom token format: { id: ..., email: ..., role: ... }
      req.user = decoded;
    }
    
    next();
  });
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
