const { Pool } = require('pg');
require('dotenv').config();

// Get database URL from environment
const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  console.warn('⚠️  DATABASE_URL not found in environment variables');
}

const pool = new Pool({
  connectionString: databaseUrl,
  ssl: {
    rejectUnauthorized: false // Required for Supabase connections
  },
  // Connection pool settings for faster startup
  max: 10, // Maximum number of clients in the pool
  idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
  connectionTimeoutMillis: 10000, // Increased to 10 seconds for IPv6 connections
  // Force IPv4 if IPv6 is causing issues
  // Note: Node.js pg library should handle this automatically, but we can set keepAlive
  keepAlive: true,
  keepAliveInitialDelayMillis: 10000,
});

pool.on('error', (err) => {
  console.error('⚠️  Database pool error:', err.message);
  // Don't exit process, just log the error
});

// Test database connection asynchronously (non-blocking startup)
setTimeout(() => {
  if (!databaseUrl) {
    console.warn('⚠️  DATABASE_URL not set - skipping connection test');
    return;
  }

  // Extract hostname from connection string for better error messages
  let hostname = 'unknown';
  try {
    const url = new URL(databaseUrl);
    hostname = url.hostname;
  } catch (e) {
    // If URL parsing fails, try to extract from connection string
    const match = databaseUrl.match(/@([^:]+)/);
    if (match) hostname = match[1];
  }

  pool.query('SELECT NOW()', (err, res) => {
    if (err) {
      console.warn('⚠️  Database connection test failed');
      console.warn(`   Hostname: ${hostname}`);
      
      if (err.code === 'ENOTFOUND') {
        console.warn('   Error: DNS resolution failed - hostname not found');
        console.warn('   Possible causes:');
        console.warn('   1. Incorrect DATABASE_URL in .env file');
        console.warn('   2. Supabase project URL is wrong');
        console.warn('   3. Network connectivity issues');
        console.warn('   Check your DATABASE_URL format:');
        console.warn('   postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres');
      } else if (err.code === 'ETIMEDOUT') {
        console.warn('   Error: Connection timeout');
        console.warn('   Check your network connection and firewall settings');
      } else {
        console.warn(`   Error: ${err.message}`);
      }
      
      console.warn('   Server will continue, but database queries may fail');
    } else {
      console.log('✅ Database connection verified');
    }
  });
}, 100); // Test after 100ms, non-blocking

module.exports = pool;
