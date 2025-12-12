const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config();

// Validate environment variables
try {
  const { validateEnvironment } = require('./config/validateEnv');
  validateEnvironment();
} catch (error) {
  console.warn('⚠️  Could not validate environment. Continuing anyway...');
}

const app = express();
const PORT = process.env.PORT || 8080;

// CORS configuration
const allowedOrigins = process.env.ALLOWED_ORIGINS 
  ? process.env.ALLOWED_ORIGINS.split(',')
  : ['*'];

app.use(cors({
  origin: allowedOrigins.includes('*') ? '*' : allowedOrigins,
  credentials: true
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const authRoutes = require('./routes/auth');
const complaintRoutes = require('./routes/complaints');
const userRoutes = require('./routes/users');
const authorityRoutes = require('./routes/authority');

app.use('/api/auth', authRoutes);
app.use('/api/complaints', complaintRoutes);
app.use('/api/users', userRoutes);
app.use('/api/authority', authorityRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'CiviX API Server is running' });
});

app.listen(PORT, () => {
  console.log(`🚀 CiviX Backend Server running on port ${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🗄️  Database: ${process.env.DATABASE_URL ? '✅ Configured' : '❌ Not configured'}`);
  console.log(`☁️  Supabase: ${process.env.SUPABASE_URL ? '✅ Configured' : '❌ Not configured'}`);
  console.log(`🤖 Gemini AI: ${process.env.GEMINI_KEY || process.env.GEMINI_API_KEY ? '✅ Configured' : '❌ Not configured'}`);
  const jwtSecret = process.env.JWT_SECRET || process.env.SUPABASE_JWT_SECRET;
  console.log(`🔐 JWT Secret: ${jwtSecret ? '✅ Configured' : '❌ Not configured'}`);
  if (jwtSecret) {
    console.log(`   Using: ${process.env.JWT_SECRET ? 'JWT_SECRET' : 'SUPABASE_JWT_SECRET'}`);
  }
  console.log(`\n✅ Server is ready to accept connections!`);
  console.log(`   Health check: http://localhost:${PORT}/api/health\n`);
});
