# .env File Setup Instructions

## 📍 File Location

**Create this file:**
```
backend/.env
```

**Full path on your system:**
```
C:\Users\miray\OneDrive\Desktop\CiviX Local\backend\.env
```

## 🎯 Quick Steps

### 1. Navigate to Backend Folder
```bash
cd "C:\Users\miray\OneDrive\Desktop\CiviX Local\backend"
```

### 2. Create .env File
```powershell
# In PowerShell
New-Item -Path .env -ItemType File
```

Or create it manually in your text editor.

### 3. Get Supabase JWT Secret

1. **Open:** https://supabase.com/dashboard
2. **Select your project**
3. **Go to:** Settings → API
4. **Scroll down** to find **"JWT Secret"**
5. **Copy the entire JWT Secret** (it's a long string)

### 4. Paste This Template

Open `backend/.env` and paste this:

```env
# Server
PORT=8080
NODE_ENV=development

# Database (from Supabase Dashboard → Settings → Database)
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres

# Supabase (from Supabase Dashboard → Settings → API)
SUPABASE_URL=https://[PROJECT-REF].supabase.co
SUPABASE_SERVICE_ROLE_KEY=[SERVICE-ROLE-KEY]
SUPABASE_JWT_SECRET=[PASTE-SUPABASE-JWT-SECRET-HERE]

# Authentication - Use the SAME value as SUPABASE_JWT_SECRET
JWT_SECRET=[PASTE-SUPABASE-JWT-SECRET-HERE]

# Google Cloud
GOOGLE_STT_KEY=./config/gcp-service-account-key.json
GOOGLE_PROJECT_ID=[YOUR-GCP-PROJECT-ID]

# Gemini API
GEMINI_KEY=[YOUR-GEMINI-API-KEY]
```

### 5. Replace Placeholders

- `[YOUR-PASSWORD]` → Your Supabase database password
- `[PROJECT-REF]` → Your project reference (from Supabase URL)
- `[SERVICE-ROLE-KEY]` → From Supabase Dashboard → Settings → API → **service_role** key
- `[PASTE-SUPABASE-JWT-SECRET-HERE]` → **Paste Supabase JWT Secret here (in both places)**
- `[YOUR-GCP-PROJECT-ID]` → Your Google Cloud project ID
- `[YOUR-GEMINI-API-KEY]` → From https://makersuite.google.com/app/apikey

## 📸 Visual Guide

### Where to Find Supabase JWT Secret:

```
Supabase Dashboard
  └── Your Project
      └── Settings (⚙️ icon)
          └── API
              ├── Project URL → SUPABASE_URL
              ├── service_role key → SUPABASE_SERVICE_ROLE_KEY
              └── JWT Secret → SUPABASE_JWT_SECRET (copy this!)
```

### Where to Paste:

```
backend/
  └── .env  ← Create this file and paste your config here
```

## ✅ Verify Setup

After creating `.env` file:

```bash
cd backend
npm run check-env
```

You should see:
```
✅ Environment variables validated
```

## 🔑 Important Notes

1. **JWT_SECRET and SUPABASE_JWT_SECRET should be the SAME value**
   - Both should contain the JWT Secret from Supabase Dashboard

2. **File name must be exactly `.env`**
   - Not `.env.txt` or `env`
   - The dot (.) at the start is important

3. **Never commit `.env` to Git**
   - It contains secrets!

## 📋 Complete Example

Here's what your `.env` file should look like (with real values):

```env
PORT=8080
NODE_ENV=development

DATABASE_URL=postgresql://postgres:mypassword123@db.abcdefghijklmnop.supabase.co:5432/postgres

SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNjQ1Mjg5NjAwLCJleHAiOjE5NjA4NjU2MDB9.xxxxx

SUPABASE_JWT_SECRET=your-super-secret-jwt-key-from-supabase-dashboard-min-32-chars
JWT_SECRET=your-super-secret-jwt-key-from-supabase-dashboard-min-32-chars

GOOGLE_STT_KEY=./config/gcp-service-account-key.json
GOOGLE_PROJECT_ID=my-gcp-project-123456

GEMINI_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567890
```

## 🚀 Next Steps

1. ✅ Create `backend/.env` file
2. ✅ Paste Supabase JWT Secret in both `SUPABASE_JWT_SECRET` and `JWT_SECRET`
3. ✅ Fill in other values
4. ✅ Run `npm run check-env` to verify
5. ✅ Start server: `npm start`

## 📚 More Help

- **Detailed guide:** See `SUPABASE_JWT_SETUP.md`
- **Quick start:** See `QUICK_START_ENV.md`
- **File location:** See `ENV_FILE_PATH.md`
- **All credentials:** See `CREDENTIALS_GUIDE.md`
