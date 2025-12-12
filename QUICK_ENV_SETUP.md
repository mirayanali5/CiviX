# Quick Environment Setup Guide

Based on your existing `.env` structure, here's how to configure everything.

## Your Current .env Structure

```env
# Server port
PORT=8080

# Supabase
SUPABASE_URL=""
SUPABASE_SERVICE_ROLE_KEY=""

# Gemini
GEMINI_KEY=""

# Google service account key JSON file paths (server runtime)
GOOGLE_STT_KEY=""
GOOGLE_TRANSLATE_KEY=""
GOOGLE_PROJECT_ID=""

GOOGLE_CLIENT_EMAIL=""
GOOGLE_PRIVATE_KEY=""
```

## Updated .env Template

```env
# Server port
PORT=8080
NODE_ENV=development

# Database (PostgreSQL)
DATABASE_URL=postgresql://user:password@localhost:5432/civix

# Supabase Storage
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Gemini AI
GEMINI_KEY=your-gemini-api-key-here

# Google Cloud - Option 1: Using JSON file path
GOOGLE_STT_KEY=./config/gcp-service-account-key.json
GOOGLE_PROJECT_ID=your-gcp-project-id

# Google Cloud - Option 2: Using direct credentials (if not using file)
# GOOGLE_CLIENT_EMAIL=your-service-account@project-id.iam.gserviceaccount.com
# GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
# GOOGLE_PROJECT_ID=your-gcp-project-id

# JWT Secret (generate with: npm run generate-jwt)
JWT_SECRET=your-jwt-secret-here-min-32-characters
```

## What Changed

1. ✅ **Bucket names updated** - Now uses:
   - `complaint-images` (for photos)
   - `complaint-audio` (for audio)
   - `resolution-images` (for resolution photos)

2. ✅ **Environment variables mapped:**
   - `SUPABASE_SERVICE_ROLE_KEY` → Used for Supabase
   - `GEMINI_KEY` → Used for Gemini AI
   - `GOOGLE_STT_KEY` → Used for Google Cloud (can be file path or use direct credentials)
   - `GOOGLE_PROJECT_ID` → Used for Google Cloud

3. ✅ **Added support for:**
   - Direct Google credentials (`GOOGLE_CLIENT_EMAIL`, `GOOGLE_PRIVATE_KEY`)
   - JWT secret generation
   - Database URL

## Where to Find Each Credential

### 1. SUPABASE_URL & SUPABASE_SERVICE_ROLE_KEY
- **Go to:** https://supabase.com/dashboard
- **Select project** → Settings → API
- **Copy:** Project URL → `SUPABASE_URL`
- **Copy:** service_role key → `SUPABASE_SERVICE_ROLE_KEY`

### 2. GEMINI_KEY
- **Go to:** https://makersuite.google.com/app/apikey
- **Create API key** → Copy to `GEMINI_KEY`

### 3. GOOGLE_STT_KEY & GOOGLE_PROJECT_ID
**Option A: JSON File (Recommended)**
- **Go to:** https://console.cloud.google.com
- **Create service account** → Download JSON key
- **Save as:** `backend/config/gcp-service-account-key.json`
- **Set:** `GOOGLE_STT_KEY=./config/gcp-service-account-key.json`
- **Set:** `GOOGLE_PROJECT_ID=your-project-id`

**Option B: Direct Credentials**
- **From JSON file, extract:**
  - `client_email` → `GOOGLE_CLIENT_EMAIL`
  - `private_key` → `GOOGLE_PRIVATE_KEY`
  - `project_id` → `GOOGLE_PROJECT_ID`

### 4. DATABASE_URL
- **Local:** `postgresql://user:password@localhost:5432/civix`
- **Supabase:** Get from Supabase Dashboard → Settings → Database

### 5. JWT_SECRET
```bash
cd backend
npm run generate-jwt
# Copy output to .env
```

## Verify Setup

```bash
cd backend
npm run check-env
npm start
```

You should see all ✅ green checkmarks!

## Storage Buckets Setup

Make sure these buckets exist in Supabase:
1. **complaint-images** - For complaint photos
2. **complaint-audio** - For audio recordings  
3. **resolution-images** - For resolution photos

Create them in: Supabase Dashboard → Storage → Buckets

---

**See `CREDENTIALS_GUIDE.md` for detailed instructions on finding each credential.**
