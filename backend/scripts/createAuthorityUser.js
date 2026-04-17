
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/database');
require('dotenv').config();

async function createAuthorityUser(email, password, department, fullName) {
  try {
    const emailNorm = (email || '').trim().toLowerCase();
    if (!emailNorm || !password || !department) {
      console.log('❌ Email, password, and department are required');
      return;
    }

    // Check if user already exists (case-insensitive)
    const existing = await pool.query(
      'SELECT id FROM profiles WHERE LOWER(TRIM(email)) = $1',
      [emailNorm]
    );

    if (existing.rows.length > 0) {
      console.log('❌ User already exists with this email. Use a different email or update the existing profile.');
      return;
    }

    const userId = uuidv4();

    // Insert authority user with plain text password (profiles.password)
    const result = await pool.query(
      `INSERT INTO profiles (id, email, full_name, role, account_type, department, password)
       VALUES ($1::uuid, $2, $3, 'authority', 'public', $4, $5)
       RETURNING id, email, full_name, role, department`,
      [userId, emailNorm, fullName || 'Authority User', department, password]
    );

    console.log('✅ Authority user created successfully!');
    console.log('User details:');
    console.log(JSON.stringify(result.rows[0], null, 2));
    console.log('\nYou can now login with:');
    console.log(`Email: ${email}`);
    console.log(`Password: ${password}`);
  } catch (error) {
    console.error('❌ Error creating authority user:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Get command line arguments
const args = process.argv.slice(2);

if (args.length < 3) {
  console.log('Usage: node scripts/createAuthorityUser.js <email> <password> <department> [full_name]');
  console.log('\nExample:');
  console.log('node scripts/createAuthorityUser.js authority@ghmc.gov.in mypassword "GHMC Sanitation" "GHMC Authority"');
  process.exit(1);
}

const [email, password, department, fullName] = args;

createAuthorityUser(email, password, department, fullName);
