const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Get Supabase credentials from environment
// Support both SUPABASE_SERVICE_ROLE_KEY and SUPABASE_SERVICE_KEY
const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_KEY || '';

if (!supabaseUrl) {
  console.warn('⚠️  SUPABASE_URL not found in environment variables. File uploads will not work.');
}

if (!supabaseKey) {
  console.warn('⚠️  SUPABASE_SERVICE_ROLE_KEY not found. File uploads will not work.');
  console.warn('   Please set SUPABASE_SERVICE_ROLE_KEY in your .env file');
}

const supabase = supabaseUrl && supabaseKey 
  ? createClient(supabaseUrl, supabaseKey)
  : null;

module.exports = supabase;
