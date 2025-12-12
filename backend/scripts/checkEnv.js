/**
 * Check environment configuration
 * Run: node scripts/checkEnv.js
 */
require('dotenv').config();
const { validateEnvironment } = require('../config/validateEnv');

console.log('🔍 Checking CiviX Backend Environment Configuration...\n');
validateEnvironment();

console.log('\n📋 Current Configuration:');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log(`PORT: ${process.env.PORT || 'Not set (default: 8080)'}`);
console.log(`DATABASE_URL: ${process.env.DATABASE_URL ? '✅ Set' : '❌ Not set'}`);
console.log(`SUPABASE_URL: ${process.env.SUPABASE_URL ? '✅ Set' : '❌ Not set'}`);
console.log(`SUPABASE_SERVICE_ROLE_KEY: ${process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_KEY ? '✅ Set' : '❌ Not set'}`);
console.log(`JWT_SECRET: ${process.env.JWT_SECRET ? '✅ Set' : '❌ Not set'}`);
console.log(`GEMINI_KEY: ${process.env.GEMINI_KEY || process.env.GEMINI_API_KEY ? '✅ Set' : '❌ Not set'}`);
console.log(`GOOGLE_PROJECT_ID: ${process.env.GOOGLE_PROJECT_ID || process.env.GOOGLE_CLOUD_PROJECT_ID ? '✅ Set' : '❌ Not set'}`);
console.log(`GOOGLE_STT_KEY: ${process.env.GOOGLE_STT_KEY || process.env.GOOGLE_APPLICATION_CREDENTIALS ? '✅ Set' : '❌ Not set'}`);
console.log(`GOOGLE_CLIENT_EMAIL: ${process.env.GOOGLE_CLIENT_EMAIL ? '✅ Set' : '❌ Not set (optional if using GOOGLE_STT_KEY)'}`);
console.log(`GOOGLE_PRIVATE_KEY: ${process.env.GOOGLE_PRIVATE_KEY ? '✅ Set' : '❌ Not set (optional if using GOOGLE_STT_KEY)'}`);
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
