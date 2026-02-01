const { Pool } = require('pg');
const dns = require('dns');
require('dotenv').config();

// Get database URL from environment
let databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  console.warn('⚠️  DATABASE_URL not found in environment variables');
}

// Force IPv4 for DB host (fixes ENETUNREACH on Render when Supabase resolves to IPv6)
if (databaseUrl && databaseUrl.startsWith('postgresql://')) {
  try {
    const url = new URL(databaseUrl);
    const hostname = url.hostname;
    // Skip if already an IP; skip pooler (often has IPv4)
    const isPooler = hostname && hostname.includes('pooler.supabase.com');
    const isIp = hostname && /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.test(hostname);
    if (hostname && !isIp && !hostname.startsWith('[') && !isPooler) {
      const ipv4 = dns.lookupSync(hostname, { family: 4 });
      url.hostname = ipv4;
      databaseUrl = url.toString();
    }
  } catch (e) {
    // Host likely has no IPv4 (e.g. Supabase direct db.xxx.supabase.co). Use pooler URL instead.
    console.warn('⚠️  DB host has no IPv4; connection may fail on Render.');
    console.warn('   Fix: In Render → Environment, set DATABASE_URL to Supabase Connection pooler (Session mode) URL.');
    console.warn('   Get it: Supabase Dashboard → Project Settings → Database → Connection pooling → Session mode → URI');
  }
}

const pool = new Pool({
  connectionString: databaseUrl,
  ssl: {
    rejectUnauthorized: false // Required for Supabase connections
  },
  // Connection pool settings
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 30000, // 30s for cross-region (e.g. Render → Supabase pooler ap-south-1)
  keepAlive: true,
  keepAliveInitialDelayMillis: 10000,
});

pool.on('error', (err) => {
  console.error('⚠️  Database pool error:', err.message);
  // Don't exit process, just log the error
});

// Test database connection after a short delay (lets server finish startup)
setTimeout(() => {
  if (!databaseUrl) {
    console.warn('⚠️  DATABASE_URL not set - skipping connection test');
    return;
  }

  let hostname = 'unknown';
  try {
    const url = new URL(databaseUrl);
    hostname = url.hostname;
  } catch (e) {
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
