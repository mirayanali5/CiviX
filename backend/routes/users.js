const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const { authenticateToken, requireAuth } = require('../middleware/auth');

// Get user dashboard stats
router.get('/dashboard', requireAuth, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user's complaint stats
    const statsResult = await pool.query(
      `SELECT 
        COUNT(*) FILTER (WHERE status = 'open') as open_complaints,
        COUNT(*) FILTER (WHERE status = 'resolved') as resolved_complaints,
        COUNT(*) as total_complaints
       FROM complaints
       WHERE user_id = $1::uuid`,
      [userId]
    );

    // Get upvoted complaints count
    const upvotedResult = await pool.query(
      `SELECT COUNT(DISTINCT complaint_id) as upvoted_count
       FROM upvotes
       WHERE user_id = $1`,
      [userId]
    );

    const stats = statsResult.rows[0];
    const totalWithUpvotes = parseInt(stats.total_complaints) + parseInt(upvotedResult.rows[0].upvoted_count || 0);

    res.json({
      open_complaints: parseInt(stats.open_complaints || 0),
      resolved_complaints: parseInt(stats.resolved_complaints || 0),
      total_complaints: totalWithUpvotes
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user's complaints
router.get('/my-complaints', requireAuth, async (req, res) => {
  try {
    const userId = req.user.id;
    const { status, limit = 50, offset = 0 } = req.query;

    let query = `
      SELECT c.*, 
        COUNT(DISTINCT u.id) as upvote_count
      FROM complaints c
      LEFT JOIN upvotes u ON c.id = u.complaint_id
      WHERE c.user_id = $1
    `;
    const params = [userId];
    let paramIndex = 2;

    if (status) {
      query += ` AND c.status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    query += ` GROUP BY c.id
               ORDER BY c.created_at DESC
               LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await pool.query(query, params);

    res.json({
      complaints: result.rows,
      total: result.rows.length
    });
  } catch (error) {
    console.error('Get my complaints error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user profile
router.get('/profile', requireAuth, async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT id, full_name as name, email, role, account_type, created_at,
        (SELECT COUNT(*) FROM complaints WHERE user_id = $1::uuid) as total_complaints
       FROM profiles
       WHERE id = $1::uuid`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user: result.rows[0] });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
