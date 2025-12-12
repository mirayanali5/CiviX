# CiviX Credentials Setup Guide

Complete guide to finding and configuring all required credentials for CiviX backend.

## Required Credentials Checklist

- [ ] **Supabase URL** - Your Supabase project URL
- [ ] **Supabase Service Role Key** - For file uploads
- [ ] **Gemini API Key** - For AI classification
- [ ] **Google Cloud Project ID** - Your GCP project
- [ ] **Google Service Account Key** - For Speech-to-Text and Translation
- [ ] **Database URL** - PostgreSQL connection string
- [ ] **JWT Secret** - Generate with `npm run generate-jwt`

---

## 1. Supabase Credentials

### Where to Find:

1. **Go to:** https://supabase.com/dashboard
2. **Select your project** (or create a new one)
3. **Go to:** Settings → API
4. **Find:**
   - **Project URL** → Copy to `SUPABASE_URL`
   - **service_role key** (under Service Role) → Copy to `SUPABASE_SERVICE_ROLE_KEY`
     - ⚠️ **Important:** Use `service_role` key, NOT `anon` key (for file uploads)

### Storage Buckets Setup:

1. **Go to:** Storage → Buckets
2. **Create 3 buckets:**
   - `complaint-images` (for complaint photos)
   - `complaint-audio` (for audio recordings)
   - `resolution-images` (for resolution photos)
3. **For each bucket:**
   - Set to **Public** if you want public URLs
   - Or keep private and use signed URLs

### Example:
```env
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNjQ1Mjg5NjAwLCJleHAiOjE5NjA4NjU2MDB9.xxxxx
```

---

## 2. Google Gemini API Key

### Where to Find:

1. **Go to:** https://makersuite.google.com/app/apikey
   - Or: https://aistudio.google.com/app/apikey
2. **Sign in** with your Google account
3. **Click:** "Create API Key"
4. **Copy the key** → Paste to `GEMINI_KEY`

### Alternative Method:

1. **Go to:** https://console.cloud.google.com
2. **Enable:** Generative Language API
3. **Go to:** APIs & Services → Credentials
4. **Create API Key** → Restrict to Generative Language API

### Example:
```env
GEMINI_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567890
```

---

## 3. Google Cloud Platform Credentials

### Step 1: Create GCP Project

1. **Go to:** https://console.cloud.google.com
2. **Click:** "Select a project" → "New Project"
3. **Enter project name:** e.g., "CiviX"
4. **Note the Project ID** → This is your `GOOGLE_PROJECT_ID`

### Step 2: Enable Required APIs

1. **Go to:** APIs & Services → Library
2. **Enable these APIs:**
   - **Cloud Speech-to-Text API**
   - **Cloud Translation API**

### Step 3: Create Service Account

1. **Go to:** IAM & Admin → Service Accounts
2. **Click:** "Create Service Account"
3. **Enter name:** e.g., "civix-audio-service"
4. **Grant roles:**
   - Cloud Speech-to-Text API User
   - Cloud Translation API User
5. **Click:** "Done"

### Step 4: Create and Download Key

**Option A: Download JSON Key File (Recommended)**

1. **Click on the service account** you just created
2. **Go to:** Keys tab
3. **Click:** "Add Key" → "Create new key"
4. **Select:** JSON
5. **Download** the JSON file
6. **Save it** in `backend/config/gcp-service-account-key.json`
7. **Set in .env:**
   ```env
   GOOGLE_STT_KEY=./config/gcp-service-account-key.json
   GOOGLE_PROJECT_ID=your-project-id
   ```

**Option B: Use Direct Credentials**

1. **Open the downloaded JSON file**
2. **Extract these values:**
   - `client_email` → `GOOGLE_CLIENT_EMAIL`
   - `private_key` → `GOOGLE_PRIVATE_KEY`
   - `project_id` → `GOOGLE_PROJECT_ID`
3. **Set in .env:**
   ```env
   GOOGLE_CLIENT_EMAIL=your-service-account@project-id.iam.gserviceaccount.com
   GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   GOOGLE_PROJECT_ID=your-project-id
   ```
   ⚠️ **Note:** Keep the `\n` characters in `GOOGLE_PRIVATE_KEY`

### Example JSON Structure:
```json
{
  "type": "service_account",
  "project_id": "civix-project-123456",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "civix-service@civix-project-123456.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

---

## 4. Database URL

### Option A: Local PostgreSQL

1. **Install PostgreSQL** if not already installed
2. **Create database:**
   ```sql
   CREATE DATABASE civix;
   ```
3. **Create user** (optional):
   ```sql
   CREATE USER civix_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE civix TO civix_user;
   ```
4. **Format:**
   ```env
   DATABASE_URL=postgresql://civix_user:your_password@localhost:5432/civix
   ```

### Option B: Supabase Database

1. **Go to:** Supabase Dashboard → Settings → Database
2. **Find:** Connection string (under Connection pooling)
3. **Copy:** Connection string
4. **Format:**
   ```env
   DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres
   ```
   ⚠️ Replace `[YOUR-PASSWORD]` with your actual database password

### Option C: Other Cloud Providers

- **Railway:** Get connection string from project settings
- **Heroku Postgres:** Get from Heroku dashboard
- **AWS RDS:** Get from RDS console

---

## 5. JWT Secret

### Generate:

```bash
cd backend
npm run generate-jwt
```

**Output example:**
```
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
```

**Copy this to your .env file.**

---

## Complete .env Example

```env
# Server
PORT=8080
NODE_ENV=development

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/civix

# Supabase
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Gemini
GEMINI_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567890

# Google Cloud (Option 1: JSON file)
GOOGLE_STT_KEY=./config/gcp-service-account-key.json
GOOGLE_PROJECT_ID=civix-project-123456

# Google Cloud (Option 2: Direct credentials)
# GOOGLE_CLIENT_EMAIL=civix-service@civix-project-123456.iam.gserviceaccount.com
# GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
# GOOGLE_PROJECT_ID=civix-project-123456

# JWT
JWT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
```

---

## Verification

### Check Configuration:

```bash
cd backend
npm run check-env
```

### Test Backend:

```bash
npm start
```

You should see:
```
🚀 CiviX Backend Server running on port 8080
📝 Environment: development
🗄️  Database: ✅ Configured
☁️  Supabase: ✅ Configured
🤖 Gemini AI: ✅ Configured
🔐 JWT Secret: ✅ Configured
```

---

## Troubleshooting

### "Supabase credentials not found"
- Check `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are set
- Verify you're using `service_role` key, not `anon` key

### "Google Cloud credentials not configured"
- Verify `GOOGLE_STT_KEY` path is correct (if using file)
- Or verify `GOOGLE_CLIENT_EMAIL` and `GOOGLE_PRIVATE_KEY` are set (if using direct)
- Check `GOOGLE_PROJECT_ID` is set
- Ensure APIs are enabled in GCP Console

### "Gemini API key not found"
- Check `GEMINI_KEY` is set correctly
- Verify API key is valid at https://makersuite.google.com

### "Database connection error"
- Verify `DATABASE_URL` format is correct
- Check database server is running
- Verify credentials are correct

---

## Security Best Practices

1. **Never commit `.env` file** to version control
2. **Use `service_role` key** only on backend (never expose to frontend)
3. **Restrict API keys** in Google Cloud Console
4. **Use strong JWT secret** (at least 32 characters)
5. **Rotate credentials** periodically
6. **Use environment-specific** `.env` files (dev, staging, prod)

---

## Additional Resources

- **Supabase Docs:** https://supabase.com/docs
- **Google Cloud Docs:** https://cloud.google.com/docs
- **Gemini API Docs:** https://ai.google.dev/docs
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
