# Quick Start: Setting Up .env File

## 📍 File Location

Create `.env` file here:
```
backend/.env
```

**Full path:**
```
C:\Users\miray\OneDrive\Desktop\CiviX Local\backend\.env
```

## 🚀 Quick Setup (5 minutes)

### Step 1: Create .env File

```bash
cd backend
# Create the file (choose one method)
touch .env          # Mac/Linux
New-Item .env       # Windows PowerShell
```

### Step 2: Get Supabase JWT Secret

1. Go to: https://supabase.com/dashboard
2. Select your project
3. Go to: **Settings → API**
4. Scroll to: **JWT Secret**
5. **Copy the entire JWT Secret string**

### Step 3: Paste This Template

Open `backend/.env` and paste:

```env
PORT=8080
NODE_ENV=development

# Database (from Supabase Dashboard → Settings → Database)
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres

# Supabase (from Supabase Dashboard → Settings → API)
SUPABASE_URL=https://[PROJECT-REF].supabase.co
SUPABASE_SERVICE_ROLE_KEY=[SERVICE-ROLE-KEY]
SUPABASE_JWT_SECRET=[PASTE-JWT-SECRET-HERE]

# Use the SAME value as SUPABASE_JWT_SECRET above
JWT_SECRET=[PASTE-JWT-SECRET-HERE]

# Google Cloud
GOOGLE_STT_KEY=./config/gcp-service-account-key.json
GOOGLE_PROJECT_ID=[YOUR-GCP-PROJECT-ID]

# Gemini
GEMINI_KEY=[YOUR-GEMINI-API-KEY]
```

### Step 4: Fill in the Values

Replace the placeholders with your actual values:

- `[PASSWORD]` → Your Supabase database password
- `[PROJECT-REF]` → Your Supabase project reference (from URL)
- `[SERVICE-ROLE-KEY]` → From Supabase Dashboard → Settings → API → service_role key
- `[PASTE-JWT-SECRET-HERE]` → **Paste Supabase JWT Secret here (twice)**
- `[YOUR-GCP-PROJECT-ID]` → Your Google Cloud project ID
- `[YOUR-GEMINI-API-KEY]` → From https://makersuite.google.com/app/apikey

### Step 5: Verify

```bash
cd backend
npm run check-env
```

You should see all ✅ checkmarks!

## 📋 Where to Find Each Value

| Value | Where to Find |
|-------|---------------|
| `DATABASE_URL` | Supabase Dashboard → Settings → Database → Connection string |
| `SUPABASE_URL` | Supabase Dashboard → Settings → API → Project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Dashboard → Settings → API → service_role key |
| `SUPABASE_JWT_SECRET` | Supabase Dashboard → Settings → API → JWT Secret |
| `JWT_SECRET` | **Same as SUPABASE_JWT_SECRET** |
| `GEMINI_KEY` | https://makersuite.google.com/app/apikey |
| `GOOGLE_PROJECT_ID` | Google Cloud Console → Your project |

## ✅ Example

```env
PORT=8080
NODE_ENV=development

DATABASE_URL=postgresql://postgres:mypassword@db.abcdefgh.supabase.co:5432/postgres

SUPABASE_URL=https://abcdefgh.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-super-secret-jwt-key-from-supabase-dashboard
JWT_SECRET=your-super-secret-jwt-key-from-supabase-dashboard

GOOGLE_STT_KEY=./config/gcp-key.json
GOOGLE_PROJECT_ID=my-project-123

GEMINI_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz
```

## 🎯 That's It!

Now you can start the server:

```bash
npm start
```

See `SUPABASE_JWT_SETUP.md` for detailed instructions.
