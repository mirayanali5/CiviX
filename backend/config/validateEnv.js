require('dotenv').config();

const requiredEnvVars = [
  'DATABASE_URL',
  'JWT_SECRET', // Can use SUPABASE_JWT_SECRET as fallback
  'SUPABASE_URL',
  'SUPABASE_SERVICE_ROLE_KEY', // Primary, but also check SUPABASE_SERVICE_KEY
];

const optionalEnvVars = {
  'GOOGLE_PROJECT_ID': 'Audio transcription will be disabled',
  'GOOGLE_STT_KEY': 'Audio transcription will be disabled',
  'GOOGLE_CLIENT_EMAIL': 'Audio transcription will be disabled (if not using GOOGLE_STT_KEY)',
  'GOOGLE_PRIVATE_KEY': 'Audio transcription will be disabled (if not using GOOGLE_STT_KEY)',
  'GEMINI_KEY': 'Department classification will use keyword-only mode',
  'GEMINI_API_KEY': 'Department classification will use keyword-only mode (alternative)',
  'GOOGLE_MAPS': 'Google Maps API key for map features',
};

function validateEnvironment() {
  const missing = [];
  const warnings = [];

  // Check required variables
  for (const varName of requiredEnvVars) {
    // Special handling for SUPABASE_SERVICE_ROLE_KEY
    if (varName === 'SUPABASE_SERVICE_ROLE_KEY') {
      if (!process.env.SUPABASE_SERVICE_ROLE_KEY && !process.env.SUPABASE_SERVICE_KEY) {
        missing.push('SUPABASE_SERVICE_ROLE_KEY (or SUPABASE_SERVICE_KEY)');
      }
    } 
    // Special handling for JWT_SECRET (can use SUPABASE_JWT_SECRET)
    else if (varName === 'JWT_SECRET') {
      if (!process.env.JWT_SECRET && !process.env.SUPABASE_JWT_SECRET) {
        missing.push('JWT_SECRET (or SUPABASE_JWT_SECRET)');
      }
    } 
    else if (!process.env[varName]) {
      missing.push(varName);
    }
  }

  // Check optional variables
  for (const [varName, message] of Object.entries(optionalEnvVars)) {
    // Special handling for Google Cloud credentials
    if (varName === 'GOOGLE_CLIENT_EMAIL' || varName === 'GOOGLE_PRIVATE_KEY') {
      // Only warn if GOOGLE_STT_KEY is also not set
      if (!process.env.GOOGLE_STT_KEY && !process.env[varName]) {
        warnings.push(`${varName}: ${message}`);
      }
    } else if (!process.env[varName]) {
      warnings.push(`${varName}: ${message}`);
    }
  }
  
  // Check if at least one Google Cloud credential method is provided
  const hasGoogleCredentials = 
    process.env.GOOGLE_STT_KEY || 
    (process.env.GOOGLE_CLIENT_EMAIL && process.env.GOOGLE_PRIVATE_KEY && process.env.GOOGLE_PROJECT_ID);
  
  if (!hasGoogleCredentials && !warnings.some(w => w.includes('Audio transcription'))) {
    warnings.push('Google Cloud credentials: Audio transcription will be disabled (set GOOGLE_STT_KEY or GOOGLE_CLIENT_EMAIL/GOOGLE_PRIVATE_KEY)');
  }
  
  // Check if at least one Gemini key is provided
  if (!process.env.GEMINI_KEY && !process.env.GEMINI_API_KEY && !warnings.some(w => w.includes('Gemini'))) {
    warnings.push('Gemini API key: Department classification will use keyword-only mode (set GEMINI_KEY or GEMINI_API_KEY)');
  }

  if (missing.length > 0) {
    console.error('❌ Missing required environment variables:');
    missing.forEach(v => console.error(`   - ${v}`));
    console.error('\nPlease set these in your .env file');
    process.exit(1);
  }

  if (warnings.length > 0) {
    console.warn('\n⚠️  Optional environment variables not set:');
    warnings.forEach(w => console.warn(`   - ${w}`));
    console.warn('\nSome features may be limited.\n');
  }

  // Validate JWT_SECRET strength
  const jwtSecret = process.env.JWT_SECRET || process.env.SUPABASE_JWT_SECRET;
  if (jwtSecret) {
    if (jwtSecret.length < 32) {
      console.warn('⚠️  JWT_SECRET should be at least 32 characters for security');
    }
  }
  
  // Warn if JWT_SECRET doesn't match SUPABASE_JWT_SECRET (but both are set)
  if (process.env.JWT_SECRET && process.env.SUPABASE_JWT_SECRET && 
      process.env.JWT_SECRET !== process.env.SUPABASE_JWT_SECRET) {
    console.warn('⚠️  JWT_SECRET and SUPABASE_JWT_SECRET should match when using Supabase Auth');
    console.warn('   Using SUPABASE_JWT_SECRET for token verification');
  }
  
  // Info: Which JWT secret will be used
  if (jwtSecret) {
    const source = process.env.JWT_SECRET ? 'JWT_SECRET' : 'SUPABASE_JWT_SECRET';
    console.log(`   JWT Secret source: ${source}`);
  }

  // Validate DATABASE_URL format
  if (process.env.DATABASE_URL && !process.env.DATABASE_URL.startsWith('postgresql://')) {
    console.warn('⚠️  DATABASE_URL should start with "postgresql://"');
  }

  console.log('✅ Environment variables validated\n');
}

module.exports = { validateEnvironment };
