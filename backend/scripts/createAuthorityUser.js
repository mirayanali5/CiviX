// Script to create an authority user with hashed password
// Usage: node scripts/createAuthorityUser.js <email> <password> <department>

const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/database');
require('dotenv').config();

async function createAuthorityUser(email, password, department, fullName) {
  try {
    // Check if user already exists
    const existing = await pool.query(
      'SELECT id FROM profiles WHERE email = $1',
      [email]
    );

    if (existing.rows.length > 0) {
      console.log('❌ User already exists with this email');
      return;
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Generate UUID
    const userId = uuidv4();

    // First, ensure password_hash column exists
    try {
      await pool.query('ALTER TABLE profiles ADD COLUMN IF NOT EXISTS password_hash TEXT');
      console.log('✅ password_hash column checked/created');
    } catch (err) {
      // Column might already exist, that's okay
      if (!err.message.includes('already exists')) {
        throw err;
      }
    }

    // Insert authority user
    const result = await pool.query(
      `INSERT INTO profiles (id, email, full_name, role, department, password_hash)
       VALUES ($1::uuid, $2, $3, 'authority', $4, $5)
       RETURNING id, email, full_name, role, department`,
      [userId, email, fullName || 'Authority User', department, passwordHash]
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
