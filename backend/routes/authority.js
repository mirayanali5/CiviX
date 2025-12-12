const express = require('express');
const router = express.Router();
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/database');
const supabase = require('../config/supabase');
const { authenticateToken, requireAuthority } = require('../middleware/auth');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }
});

async function uploadToSupabase(file, bucketName) {
  if (!supabase) {
    throw new Error('Supabase not configured');
  }

  const fileExt = file.originalname.split('.').pop();
  const fileName = `${uuidv4()}.${fileExt}`;

  const { data, error } = await supabase.storage
    .from(bucketName)
    .upload(fileName, file.buffer, {
      contentType: file.mimetype,
      upsert: false
    });

  if (error) {
    throw error;
  }

  const { data: urlData } = supabase.storage
    .from(bucketName)
    .getPublicUrl(fileName);

  return urlData.publicUrl;
}

// Get authority dashboard stats
router.get('/dashboard', requireAuthority, async (req, res) => {
  try {
    const userId = req.user.id;

    // Fetch department from profiles table
    const profileResult = await pool.query(
      'SELECT department FROM profiles WHERE id = $1::uuid',
      [userId]
    );

    if (profileResult.rows.length === 0 || !profileResult.rows[0].department) {
      return res.status(400).json({ error: 'Department not assigned to this authority user' });
    }

    const department = profileResult.rows[0].department;

    const statsResult = await pool.query(
      `SELECT 
        COUNT(*) FILTER (WHERE LOWER(status) = 'open') as open,
        COUNT(*) FILTER (WHERE LOWER(status) = 'open') as in_progress, -- Your schema only has 'open' and 'resolved'
        COUNT(*) FILTER (WHERE LOWER(status) = 'resolved') as resolved,
        COUNT(*) as total
       FROM complaints
       WHERE department = $1`,
      [department]
    );

    console.log('Dashboard stats for department:', department, statsResult.rows[0]);

    res.json({
      stats: statsResult.rows[0],
      department
    });
  } catch (error) {
    console.error('Authority dashboard error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get department complaints
router.get('/complaints', requireAuthority, async (req, res) => {
  try {
    const userId = req.user.id;

    // Fetch department from profiles table
    const profileResult = await pool.query(
      'SELECT department FROM profiles WHERE id = $1::uuid',
      [userId]
    );

    if (profileResult.rows.length === 0 || !profileResult.rows[0].department) {
      return res.status(400).json({ error: 'Department not assigned to this authority user' });
    }

    const department = profileResult.rows[0].department;
    const { status, limit = 50, offset = 0 } = req.query;

    let query = `
      SELECT c.*, 
        COUNT(DISTINCT u.id) as upvote_count,
        p.full_name as reporter_name, 
        p.account_type
      FROM complaints c
      LEFT JOIN upvotes u ON c.id = u.complaint_id
      LEFT JOIN profiles p ON c.user_id = p.id
      WHERE c.department = $1
    `;
    const params = [department];
    let paramIndex = 2;

    if (status) {
      // Normalize status to lowercase to match schema
      const normalizedStatus = status.toLowerCase();
      query += ` AND LOWER(c.status) = $${paramIndex}`;
      params.push(normalizedStatus);
      paramIndex++;
    }

    // Fix GROUP BY to include all selected columns
    query += ` GROUP BY c.id, c.user_id, c.guest_id, c.description, c.transcript, c.translated_text, 
               c.image_url, c.audio_url, c.department, c.tags, c.latitude, c.longitude, 
               c.status, c.report_count, c.created_at, c.updated_at, c.is_duplicate, 
               c.parent_complaint_id, p.full_name, p.account_type
               ORDER BY upvote_count DESC, c.created_at DESC
               LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    console.log('Fetching complaints for department:', department);
    console.log('Query params:', params);

    const result = await pool.query(query, params);

    console.log(`Found ${result.rows.length} complaints for department ${department}`);

    res.json({
      complaints: result.rows,
      total: result.rows.length
    });
  } catch (error) {
    console.error('Get department complaints error:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ 
      error: 'Internal server error',
      details: error.message 
    });
  }
});

// Get single complaint for resolution
router.get('/complaints/:id', requireAuthority, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Fetch department from profiles table
    const profileResult = await pool.query(
      'SELECT department FROM profiles WHERE id = $1::uuid',
      [userId]
    );

    if (profileResult.rows.length === 0 || !profileResult.rows[0].department) {
      return res.status(400).json({ error: 'Department not assigned to this authority user' });
    }

    const department = profileResult.rows[0].department;

    const result = await pool.query(
      `SELECT c.*, 
        COUNT(DISTINCT u.id) as upvote_count,
        p.full_name as reporter_name, 
        p.account_type
       FROM complaints c
       LEFT JOIN upvotes u ON c.id = u.complaint_id
       LEFT JOIN profiles p ON c.user_id = p.id
       WHERE c.id = $1::uuid AND c.department = $2
       GROUP BY c.id, c.user_id, c.guest_id, c.description, c.transcript, c.translated_text, 
                c.image_url, c.audio_url, c.department, c.tags, c.latitude, c.longitude, 
                c.status, c.report_count, c.created_at, c.updated_at, c.is_duplicate, 
                c.parent_complaint_id, p.full_name, p.account_type`,
      [id, department]
    );

    console.log('Get complaint for resolution:', id, 'department:', department);
    console.log('Complaint found:', result.rows.length > 0);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Complaint not found or not in your department' });
    }

    res.json({ complaint: result.rows[0] });
  } catch (error) {
    console.error('Get complaint error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update complaint status
router.patch('/complaints/:id/status', requireAuthority, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user.id;

    // Fetch department from profiles table
    const profileResult = await pool.query(
      'SELECT department FROM profiles WHERE id = $1::uuid',
      [userId]
    );

    if (profileResult.rows.length === 0 || !profileResult.rows[0].department) {
      return res.status(400).json({ error: 'Department not assigned to this authority user' });
    }

    const department = profileResult.rows[0].department;

    // Convert status to lowercase to match your schema
    const normalizedStatus = status.toLowerCase();
    if (!['open', 'resolved'].includes(normalizedStatus)) {
      return res.status(400).json({ error: 'Invalid status. Use "open" or "resolved"' });
    }

    const result = await pool.query(
      `UPDATE complaints 
       SET status = $1, updated_at = now()
       WHERE id = $2::uuid AND department = $3
       RETURNING *`,
      [normalizedStatus, id, department]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Complaint not found or not in your department' });
    }

    res.json({ complaint: result.rows[0] });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Resolve complaint
router.post('/complaints/:id/resolve', requireAuthority, upload.array('photos', 5), async (req, res) => {
  try {
    const { id } = req.params;
    const { notes } = req.body;
    const photos = req.files || [];
    const authorityUserId = req.user.id;

    // Fetch department from profiles table
    const profileResult = await pool.query(
      'SELECT department FROM profiles WHERE id = $1::uuid',
      [authorityUserId]
    );

    if (profileResult.rows.length === 0 || !profileResult.rows[0].department) {
      return res.status(400).json({ error: 'Department not assigned to this authority user' });
    }

    const department = profileResult.rows[0].department;

    if (photos.length === 0) {
      return res.status(400).json({ error: 'At least one resolution photo is required' });
    }

    // Verify complaint belongs to authority's department
    const complaintResult = await pool.query(
      'SELECT * FROM complaints WHERE id = $1::uuid AND department = $2',
      [id, department]
    );

    console.log('Resolving complaint:', id, 'for department:', department);
    console.log('Complaint found:', complaintResult.rows.length > 0);

    if (complaintResult.rows.length === 0) {
      return res.status(404).json({ error: 'Complaint not found or not in your department' });
    }

    // Upload resolution photos to resolution-images bucket
    const photoUrls = [];
    for (const photo of photos) {
      try {
        const url = await uploadToSupabase(photo, 'resolution-images');
        photoUrls.push(url);
      } catch (error) {
        console.error('Photo upload error:', error);
      }
    }

    if (photoUrls.length === 0) {
      return res.status(500).json({ error: 'Failed to upload resolution photos' });
    }

    // Create resolution record with images array (matching your schema)
    // Note: authority_id is text in schema, so convert UUID to string
    await pool.query(
      `INSERT INTO resolutions (complaint_id, authority_id, images, notes)
       VALUES ($1::uuid, $2::text, $3::text[], $4)`,
      [id, authorityUserId.toString(), photoUrls, notes || '']
    );

    // Update complaint status
    await pool.query(
      'UPDATE complaints SET status = $1, updated_at = now() WHERE id = $2::uuid',
      ['resolved', id]
    );

    res.json({
      message: 'Complaint resolved successfully',
      resolution_photos: photoUrls
    });
  } catch (error) {
    console.error('Resolve complaint error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get resolution history
router.get('/history', requireAuthority, async (req, res) => {
  try {
    const authorityUserId = req.user.id;
    const { limit = 50, offset = 0 } = req.query;

    const result = await pool.query(
      `SELECT r.*, 
        c.image_url as before_photo,
        c.transcript as complaint_description,
        c.latitude, c.longitude,
        c.created_at as complaint_created_at
       FROM resolutions r
       JOIN complaints c ON r.complaint_id = c.id
       WHERE r.authority_id = $1::text
       ORDER BY r.resolved_at DESC
       LIMIT $2 OFFSET $3`,
      [authorityUserId.toString(), parseInt(limit), parseInt(offset)]
    );

    res.json({
      resolutions: result.rows,
      total: result.rows.length
    });
  } catch (error) {
    console.error('Get history error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
