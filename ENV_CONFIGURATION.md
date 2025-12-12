# Environment Variables Configuration Guide

All backend APIs and services are configured through environment variables in the `.env` file.

## Quick Setup

1. **Copy the example file:**
```bash
cd backend
cp env.example .env
```

2. **Generate JWT secret:**
```bash
npm run generate-jwt
# Copy the output to your .env file
```

3. **Fill in all required values** in `.env`

4. **Validate configuration:**
```bash
npm run check-env
```

## Required Environment Variables

### Server Configuration
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment mode (development/production)

### Database
- `DATABASE_URL` - PostgreSQL connection string
  - Format: `postgresql://user:password@host:port/database`
  - Or use Supabase connection string

### Supabase Storage
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_KEY` - Supabase anon/public key
- `SUPABASE_SERVICE_KEY` - Supabase service role key (for admin operations)

### Authentication
- `JWT_SECRET` - Secret key for JWT token signing (min 32 characters)
  - Generate with: `npm run generate-jwt`

### Google Cloud Platform
- `GOOGLE_CLOUD_PROJECT_ID` - Your GCP project ID
- `GOOGLE_APPLICATION_CREDENTIALS` - Path to service account JSON key file
  - Required for: Speech-to-Text API, Translation API

### Google Gemini AI
- `GEMINI_API_KEY` - Your Gemini API key
  - Get from: https://makersuite.google.com/app/apikey
  - Required for: AI-powered department classification

## Optional Environment Variables

- `ALLOWED_ORIGINS` - Comma-separated list of allowed CORS origins
- `MAX_FILE_SIZE_MB` - Maximum file upload size (default: 10MB)
- `MAX_AUDIO_DURATION_SECONDS` - Maximum audio recording duration

## Where Each Variable is Used

### `DATABASE_URL`
- **Used in:** `backend/config/database.js`
- **Purpose:** PostgreSQL database connection
- **Required:** Yes

### `SUPABASE_URL`, `SUPABASE_KEY`, `SUPABASE_SERVICE_KEY`
- **Used in:** `backend/config/supabase.js`
- **Purpose:** File storage (photos, audio, resolution images)
- **Required:** Yes (for file uploads)

### `JWT_SECRET`
- **Used in:** `backend/middleware/auth.js`, `backend/routes/auth.js`
- **Purpose:** Signing and verifying JWT tokens
- **Required:** Yes

### `GOOGLE_CLOUD_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS`
- **Used in:** `backend/utils/audioProcessing.js`
- **Purpose:** Speech-to-Text and Translation APIs
- **Required:** Yes (for audio transcription)

### `GEMINI_API_KEY`
- **Used in:** `backend/utils/aiClassification.js`
- **Purpose:** AI-powered department classification
- **Required:** Yes (for AI classification fallback)

## Verification

### Check Configuration
```bash
npm run check-env
```

### Test Backend Startup
```bash
npm start
```

The server will validate environment variables on startup and show:
- ✅ Configured - Variable is set
- ❌ Not configured - Variable is missing
- ⚠️ Warning - Optional variable missing (features may be limited)

## Security Notes

1. **Never commit `.env` file** to version control
2. **Use strong JWT_SECRET** (at least 32 characters)
3. **Keep service account keys secure**
4. **Use different values** for development and production
5. **Rotate secrets** periodically in production

## Example .env File

```env
PORT=3000
NODE_ENV=development

DATABASE_URL=postgresql://user:password@localhost:5432/civix
SUPABASE_URL=https://abc123.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

JWT_SECRET=your-very-long-and-secure-secret-key-minimum-32-characters

GOOGLE_CLOUD_PROJECT_ID=my-gcp-project
GOOGLE_APPLICATION_CREDENTIALS=./config/gcp-key.json

GEMINI_API_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz
```

## Troubleshooting

### "Missing required environment variables"
- Check that `.env` file exists in `backend/` directory
- Verify all required variables are set
- Run `npm run check-env` to see which variables are missing

### "Database connection error"
- Verify `DATABASE_URL` is correct
- Check database server is running
- Verify credentials are correct

### "Supabase upload fails"
- Check `SUPABASE_SERVICE_KEY` is set (not just `SUPABASE_KEY`)
- Verify storage bucket `civix-media` exists
- Check bucket permissions

### "Audio transcription fails"
- Verify `GOOGLE_APPLICATION_CREDENTIALS` path is correct
- Check service account JSON file exists
- Verify Speech-to-Text API is enabled in GCP

### "Gemini classification fails"
- Verify `GEMINI_API_KEY` is set correctly
- Check API key is valid and not expired
- Verify API key has proper permissions
