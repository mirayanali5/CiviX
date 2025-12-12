# Environment Variables Setup Guide

This guide explains all environment variables used in the CiviX backend and how to configure them.

## Quick Start

1. Copy the example file:
   ```bash
   cp env.example .env
   ```

2. Edit `.env` and fill in your values

3. Validate your configuration:
   ```bash
   npm run validate-env
   ```

## Required Variables

### Critical (App won't work without these)

#### `DATABASE_URL`
- **Description**: PostgreSQL database connection string
- **Format**: `postgresql://username:password@host:port/database`
- **Example**: `postgresql://postgres:mypassword@localhost:5432/civix`
- **Alternative**: Use Supabase connection string

#### `JWT_SECRET`
- **Description**: Secret key for signing JWT tokens
- **Format**: Any long random string (minimum 32 characters)
- **Example**: `my-super-secret-jwt-key-12345678901234567890`
- **Security**: Use a strong random string in production!

### Important (Features will be limited without these)

#### `SUPABASE_URL`
- **Description**: Your Supabase project URL
- **Format**: `https://your-project-id.supabase.co`
- **Where to find**: Supabase Dashboard > Settings > API > Project URL
- **Required for**: File uploads (photos, audio, resolution images)

#### `SUPABASE_SERVICE_KEY`
- **Description**: Supabase service role key (has admin privileges)
- **Format**: Long JWT token
- **Where to find**: Supabase Dashboard > Settings > API > service_role key
- **Required for**: File uploads to storage buckets
- **Security**: Never expose this in frontend code!

#### `GEMINI_API_KEY`
- **Description**: Google Gemini API key for AI classification
- **Format**: API key string
- **Where to get**: https://makersuite.google.com/app/apikey
- **Required for**: AI-powered department classification

### Optional (Nice to have)

#### `SUPABASE_KEY`
- **Description**: Supabase anon/public key
- **Format**: JWT token
- **Where to find**: Supabase Dashboard > Settings > API > anon public key
- **Note**: Used as fallback if service key not available

#### `GOOGLE_CLOUD_PROJECT_ID`
- **Description**: Your Google Cloud Platform project ID
- **Format**: Project ID string
- **Where to find**: Google Cloud Console > Project Settings
- **Required for**: Speech-to-Text and Translation APIs

#### `GOOGLE_APPLICATION_CREDENTIALS`
- **Description**: Path to Google Cloud service account JSON key file
- **Format**: File path (relative or absolute)
- **Example**: `./config/gcp-service-account.json`
- **Required for**: Speech-to-Text and Translation APIs
- **How to get**: 
  1. Go to Google Cloud Console > IAM & Admin > Service Accounts
  2. Create service account
  3. Download JSON key file
  4. Place in your project directory

#### `PORT`
- **Description**: Port number for the server
- **Default**: `3000`
- **Format**: Number
- **Example**: `3000` or `8080`

#### `NODE_ENV`
- **Description**: Environment mode
- **Options**: `development`, `production`, `test`
- **Default**: `development`
- **Note**: Affects error messages and logging

#### `ALLOWED_ORIGINS`
- **Description**: Comma-separated list of allowed CORS origins
- **Format**: `http://localhost:3000,https://yourdomain.com`
- **Default**: `*` (allows all origins)
- **Note**: Set specific origins in production

## Environment-Specific Examples

### Development (.env)
```env
PORT=3000
NODE_ENV=development
DATABASE_URL=postgresql://postgres:password@localhost:5432/civix_dev
SUPABASE_URL=https://abc123.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
JWT_SECRET=dev-secret-key-change-in-production
GEMINI_API_KEY=AIzaSy...
GOOGLE_CLOUD_PROJECT_ID=my-gcp-project
GOOGLE_APPLICATION_CREDENTIALS=./config/gcp-key.json
```

### Production (.env.production)
```env
PORT=8080
NODE_ENV=production
DATABASE_URL=postgresql://user:pass@prod-db:5432/civix
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
JWT_SECRET=super-secure-random-string-min-32-chars
GEMINI_API_KEY=AIzaSy...
ALLOWED_ORIGINS=https://civix.app,https://www.civix.app
```

## Validation

Run the validation script to check your configuration:

```bash
npm run validate-env
```

This will:
- ✅ Check all required variables
- ⚠️  Warn about missing important variables
- ℹ️  Show optional variables status

## Security Best Practices

1. **Never commit `.env` file** to version control
2. **Use strong JWT_SECRET** (minimum 32 random characters)
3. **Rotate secrets regularly** in production
4. **Use different credentials** for development and production
5. **Restrict CORS origins** in production
6. **Keep service account keys secure** - never expose in frontend

## Troubleshooting

### "Missing required environment variables"
- Check that `.env` file exists in `backend/` directory
- Verify variable names match exactly (case-sensitive)
- Ensure no extra spaces around `=` sign

### "Database connection failed"
- Verify `DATABASE_URL` format is correct
- Check database is running and accessible
- Test connection: `psql $DATABASE_URL`

### "Supabase upload fails"
- Verify `SUPABASE_SERVICE_KEY` is correct (not anon key)
- Check storage bucket exists and is accessible
- Verify service key has storage permissions

### "Gemini API error"
- Verify `GEMINI_API_KEY` is valid
- Check API key hasn't expired
- Ensure Generative AI API is enabled in Google Cloud

### "Speech-to-Text not working"
- Verify `GOOGLE_APPLICATION_CREDENTIALS` path is correct
- Check service account JSON file exists
- Ensure Speech-to-Text API is enabled in GCP
- Verify service account has necessary permissions

## Testing Your Configuration

After setting up `.env`, test each service:

```bash
# Test database connection
npm run validate-env

# Test backend server
npm start
# Should see: ✅ Configured for all services

# Test API endpoint
curl http://localhost:3000/api/health
```

## Getting API Keys

### Supabase
1. Go to https://supabase.com
2. Create account/project
3. Go to Settings > API
4. Copy Project URL and service_role key

### Google Gemini
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with Google account
3. Create API key
4. Copy the key

### Google Cloud Platform
1. Go to https://console.cloud.google.com
2. Create project
3. Enable APIs: Speech-to-Text, Translation, Generative AI
4. Create service account
5. Download JSON key file

## Need Help?

- Check `SETUP_GUIDE.md` for detailed setup instructions
- Review `README.md` for project overview
- Check backend logs for specific error messages
