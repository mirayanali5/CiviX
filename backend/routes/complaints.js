const express = require('express');
const router = express.Router();
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/database');
const supabase = require('../config/supabase');
const { authenticateToken } = require('../middleware/auth');
const { classifyDepartment, generateAutoTags, DEPARTMENTS } = require('../utils/aiClassification');
const { checkDuplicate, autoUpvote } = require('../utils/duplicateDetection');
const { processAudio } = require('../utils/audioProcessing');

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB
});

/**
 * Upload file to Supabase Storage
 * Uses separate buckets: complaint-images, complaint-audio, resolution-images
 */
async function uploadToSupabase(file, bucketName) {
  if (!supabase) {
    throw new Error('Supabase not configured');
  }

  const fileExt = file.originalname.split('.').pop() || 'bin';
  const fileName = `${uuidv4()}.${fileExt}`;
  let contentType = file.mimetype;
  if (!contentType || contentType === 'application/octet-stream') {
    if (fileExt.toLowerCase() === 'm4a') contentType = 'audio/mp4';
    else if (fileExt.toLowerCase() === 'ogg') contentType = 'audio/ogg';
  }

  const { data, error } = await supabase.storage
    .from(bucketName)
    .upload(fileName, file.buffer, {
      contentType,
      upsert: false
    });

  if (error) {
    throw error;
  }

  // Get public URL
  const { data: urlData } = supabase.storage
    .from(bucketName)
    .getPublicUrl(fileName);

  return urlData.publicUrl;
}

// Create complaint - allow guest complaints (optional auth)
router.post('/', upload.fields([
  { name: 'photo', maxCount: 1 },
  { name: 'audio', maxCount: 1 }
]), async (req, res, next) => {
  // Use authenticateToken middleware which allows null users (guest complaints)
  const { authenticateToken } = require('../middleware/auth');
  authenticateToken(req, res, next);
}, async (req, res) => {
  try {
    const { description, tags, gps_lat, gps_long, department: userDepartment } = req.body;
    const photo = req.files?.photo?.[0];
    const audio = req.files?.audio?.[0];

    // Validate mandatory fields
    if (!photo) {
      return res.status(400).json({ error: 'Photo is mandatory' });
    }

    if (!gps_lat || !gps_long) {
      return res.status(400).json({ error: 'GPS coordinates are mandatory' });
    }

    const lat = parseFloat(gps_lat);
    const lon = parseFloat(gps_long);

    if (isNaN(lat) || isNaN(lon)) {
      return res.status(400).json({ error: 'Invalid GPS coordinates' });
    }

    // Validate description or audio
    // When both provided: always prefer description over audio (skip audio processing)
    let finalDescription = (description && typeof description === 'string') ? description.trim() : '';
    let rawTranscript = '';
    let translatedTranscript = '';

    if (finalDescription) {
      // Description provided - use it, skip audio transcription (still upload audio if present)
      if (audio) {
        console.log('Description provided - skipping audio transcription, will upload audio to bucket');
      }
    } else if (audio) {
      // No description - process audio (transcribe, detect language, translate if needed)
      try {
        console.log('Processing audio file:', {
          size: audio.buffer.length,
          mimetype: audio.mimetype,
          originalname: audio.originalname
        });
        
        const audioResult = await processAudio(audio.buffer);
        rawTranscript = audioResult.rawTranscript;
        translatedTranscript = audioResult.translatedTranscript;
        
        if (translatedTranscript) {
          finalDescription = translatedTranscript;
        }
      } catch (error) {
        console.error('Audio processing error:', error);
        console.error('Error details:', {
          message: error.message,
          code: error.code,
          stack: error.stack
        });
        return res.status(400).json({ 
          error: 'Audio processing failed. Please provide a text description or try again.',
          details: process.env.NODE_ENV === 'development' ? error.message : undefined
        });
      }
    }

    if (!finalDescription || finalDescription.trim() === '') {
      return res.status(400).json({ 
        error: 'Either description or audio recording is required' 
      });
    }

    // Check for duplicates
    const duplicateCheck = await checkDuplicate(lat, lon, finalDescription, req.user?.id);
    
    if (duplicateCheck.isDuplicate) {
      const existingComplaint = duplicateCheck.existingComplaint;
      
      // Auto-upvote if logged in
      if (req.user) {
        await autoUpvote(existingComplaint.id, req.user.id);
        
        // Fetch updated complaint
        const updatedResult = await pool.query(
          `SELECT c.*, 
            COUNT(DISTINCT u.id) as upvote_count,
            p.full_name as reporter_name, p.account_type
           FROM complaints c
           LEFT JOIN upvotes u ON c.id = u.complaint_id
           LEFT JOIN profiles p ON c.user_id = p.id
           WHERE c.id = $1
           GROUP BY c.id, p.full_name, p.account_type`,
          [existingComplaint.id]
        );
        
        return res.status(200).json({
          merged: true,
          message: 'Duplicate complaint found. Auto-upvoted.',
          complaint: updatedResult.rows[0]
        });
      } else {
        // Guest - just return existing complaint
        return res.status(200).json({
          merged: true,
          message: 'Duplicate complaint found.',
          complaint: existingComplaint
        });
      }
    }

    // Upload photo to complaint-images bucket
    let photoUrl;
    try {
      photoUrl = await uploadToSupabase(photo, 'complaint-images');
    } catch (error) {
      console.error('Photo upload error:', error);
      return res.status(500).json({ error: 'Failed to upload photo' });
    }

    // Upload audio to complaint-audio bucket if present
    let audioUrl = '';
    if (audio) {
      try {
        audioUrl = await uploadToSupabase(audio, 'complaint-audio');
      } catch (error) {
        console.error('Audio upload error:', error);
        // Continue without audio URL
      }
    }

    // Classify department (AI-based) as a default
    const classification = await classifyDepartment(finalDescription);

    // If citizen explicitly selected a department, prefer that over AI classification.
    // Normalize and only accept values that match our known DEPARTMENTS list.
    let finalDepartment = classification.department;
    if (userDepartment && typeof userDepartment === 'string') {
      const normalized = userDepartment.trim().toLowerCase();
      const matchedDept = DEPARTMENTS.find(
        (d) => d.trim().toLowerCase() === normalized
      );
      if (matchedDept) {
        finalDepartment = matchedDept;
      }
    }

    // Determine user_id (UUID) or guest_id (text)
    const userId = req.user ? req.user.id : null;
    const guestId = req.user ? null : `guest_${uuidv4()}`;

    // Auto-generate tags based on department and description
    const autoTags = generateAutoTags(finalDescription, finalDepartment);
    
    // Parse user-provided tags (if any)
    const userTags = tags ? (Array.isArray(tags) ? tags : tags.split(',').map(t => t.trim()).filter(t => t)) : [];
    
    // Combine auto-generated tags with user tags, removing duplicates
    const tagsArray = [...new Set([...autoTags, ...userTags])];

    // Insert complaint - match your Supabase schema
    const insertResult = await pool.query(
      `INSERT INTO complaints (
        user_id, guest_id, description, transcript, translated_text, department, 
        tags, latitude, longitude, image_url, audio_url, status
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'open')
      RETURNING *`,
      [
        userId,
        guestId,
        finalDescription,
        rawTranscript || finalDescription,
        translatedTranscript || finalDescription,
        finalDepartment,
        tagsArray,
        lat,
        lon,
        photoUrl,
        audioUrl
      ]
    );

    const complaint = insertResult.rows[0];

    res.status(201).json({
      message: 'Complaint created successfully',
      complaint: {
        ...complaint,
        merged: false
      }
    });
  } catch (error) {
    console.error('Create complaint error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all complaints (for dashboard)
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { status, department, search, limit = 50, offset = 0 } = req.query;
    const userId = req.user?.id;

    let query = `
      SELECT c.*, 
        COUNT(DISTINCT u.id) as upvote_count,
        p.full_name as reporter_name, 
        p.account_type,
        CASE 
          WHEN c.user_id = $1::uuid THEN true 
          ELSE false 
        END as is_my_complaint
      FROM complaints c
      LEFT JOIN upvotes u ON c.id = u.complaint_id
      LEFT JOIN profiles p ON c.user_id = p.id
      WHERE 1=1
    `;
    const params = [userId || null];
    let paramIndex = 2;

    // Only filter by status if explicitly provided, otherwise show all
    if (status) {
      query += ` AND c.status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    if (department) {
      query += ` AND c.department = $${paramIndex}`;
      params.push(department);
      paramIndex++;
    }

    if (search) {
      query += ` AND (c.description ILIKE $${paramIndex} OR c.transcript ILIKE $${paramIndex} OR c.department ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    query += ` GROUP BY c.id, p.full_name, p.account_type
               ORDER BY c.created_at DESC, upvote_count DESC
               LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await pool.query(query, params);

    res.json({
      complaints: result.rows,
      total: result.rows.length
    });
  } catch (error) {
    console.error('Get complaints error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single complaint
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT c.*, 
        COUNT(DISTINCT u.id) as upvote_count,
        p.full_name as reporter_name, 
        p.account_type,
        CASE 
          WHEN c.user_id = $2::uuid THEN true 
          ELSE false 
        END as is_my_complaint
       FROM complaints c
       LEFT JOIN upvotes u ON c.id = u.complaint_id
       LEFT JOIN profiles p ON c.user_id = p.id
       WHERE c.id = $1::uuid
       GROUP BY c.id, p.full_name, p.account_type`,
      [id, req.user?.id || null]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Complaint not found' });
    }

    const complaint = result.rows[0];

    // Include resolution photos for citizens when complaint is resolved
    if (complaint.status && complaint.status.toLowerCase() === 'resolved') {
      try {
        const resResult = await pool.query(
          'SELECT * FROM resolutions WHERE complaint_id = $1::uuid ORDER BY resolved_at DESC LIMIT 1',
          [id]
        );
        if (resResult.rows.length > 0) {
          const r = resResult.rows[0];
          if (r.images != null) {
            complaint.resolution_photos = Array.isArray(r.images) ? r.images : [r.images];
          } else if (r.photo_url) {
            complaint.resolution_photos = [r.photo_url];
          } else {
            complaint.resolution_photos = [];
          }
          complaint.resolution_notes = r.notes || '';
          complaint.resolved_at = r.resolved_at;
        }
      } catch (resErr) {
        console.warn('Resolution fetch for complaint:', resErr.message);
      }
    }

    res.json({ complaint });
  } catch (error) {
    console.error('Get complaint error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Upvote complaint
router.post('/:id/upvote', authenticateToken, async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required to upvote' });
    }

    const { id } = req.params;
    const userId = req.user.id;

    // Check if already upvoted
    const existing = await pool.query(
      'SELECT id FROM upvotes WHERE complaint_id = $1 AND user_id = $2',
      [id, userId]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({ error: 'Already upvoted' });
    }

    // Add upvote
    await pool.query(
      'INSERT INTO upvotes (complaint_id, user_id) VALUES ($1, $2)',
      [id, userId]
    );

    // Update report_count
    await pool.query(
      'UPDATE complaints SET report_count = report_count + 1 WHERE id = $1',
      [id]
    );

    res.json({ message: 'Upvoted successfully' });
  } catch (error) {
    console.error('Upvote error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
