const haversine = require('haversine-distance');
const stringSimilarity = require('string-similarity');
const pool = require('../config/database');

const DUPLICATE_RADIUS_METERS = 30;
const TEXT_SIMILARITY_THRESHOLD = 0.3;

/**
 * Check if a complaint is a duplicate
 * Returns { isDuplicate: boolean, existingComplaint: object | null }
 */
// async function checkDuplicate(lat, lon, description, userId = null) {
   async function checkDuplicate(lat, lon, department, description, userId = null)
   {try {
    // Get bounding box (approximately 300m)
    // const latDelta = 0.0027; // ~300m
    // const lonDelta = 0.0027;
    const latDelta = 50 / 111320;
    const lonDelta = 50 / (111320 * Math.cos(lat * Math.PI / 180));

    const query = `
      SELECT id, user_id, guest_id, transcript,department,latitude, longitude, status, report_count
      FROM complaints
      WHERE latitude BETWEEN $1 AND $2
        AND longitude BETWEEN $3 AND $4
        AND status = 'open'
        AND department = $5

    `;

    const result = await pool.query(query, [
      lat - latDelta,
      lat + latDelta,
      lon - lonDelta,
      lon + lonDelta,
      department
    ]);

    if (result.rows.length === 0) {
      return { isDuplicate: false, existingComplaint: null };
    }

      // Check each nearby complaint
    for (const complaint of result.rows) {
      const distance = haversine(
        { lat, lon },
        { lat: complaint.latitude, lon: complaint.longitude }
      );

      if (distance <= DUPLICATE_RADIUS_METERS) {
        // Check text similarity
        const similarity = stringSimilarity.compareTwoStrings(
          (description || '').toLowerCase(),
          (complaint.transcript || '').toLowerCase()
        );

        if (similarity >= TEXT_SIMILARITY_THRESHOLD) {
          return {
            isDuplicate: true,
            existingComplaint: complaint
          };
        }
      }
    }

    return { isDuplicate: false, existingComplaint: null };
  } catch (error) {
    console.error('Duplicate detection error:', error);
    return { isDuplicate: false, existingComplaint: null };
  }
}

/**
 * Auto-upvote existing complaint for logged-in user
 */
async function autoUpvote(complaintId, userId) {
  try {
    const checkQuery = `
      SELECT id FROM upvotes 
      WHERE complaint_id = $1 AND user_id = $2
    `;
    const checkResult = await pool.query(checkQuery, [complaintId, userId]);

    if (checkResult.rows.length > 0) {
      return; // Already upvoted
    }

    // Add upvote
    const insertQuery = `
      INSERT INTO upvotes (complaint_id, user_id)
      VALUES ($1, $2)
    `;
    await pool.query(insertQuery, [complaintId, userId]);

    // Update report_count
    const updateQuery = `
      UPDATE complaints 
      SET report_count = report_count + 1
      WHERE id = $1
    `;
    await pool.query(updateQuery, [complaintId]);
  } catch (error) {
    console.error('Auto-upvote error:', error);
  }
}

module.exports = { checkDuplicate, autoUpvote, DUPLICATE_RADIUS_METERS };
