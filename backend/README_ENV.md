# .env File Setup - Quick Reference

## 📍 File Location

**Path:** `backend/.env`

**Full path on Windows:**
```
C:\Users\miray\OneDrive\Desktop\CiviX Local\backend\.env
```

## 🔑 Supabase JWT Secret

### Where to Get It:
1. Go to: https://supabase.com/dashboard
2. Select your project
3. Settings → API
4. Scroll to **"JWT Secret"**
5. Copy the entire secret string

### Where to Paste It:
In your `backend/.env` file, paste it in **TWO places**:

```env
SUPABASE_JWT_SECRET=[PASTE-JWT-SECRET-HERE]
JWT_SECRET=[PASTE-JWT-SECRET-HERE]  # Same value!
```

## 📝 Complete .env Template

```env
PORT=8080
NODE_ENV=development

DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
SUPABASE_URL=https://[PROJECT-REF].supabase.co
SUPABASE_SERVICE_ROLE_KEY=[SERVICE-ROLE-KEY]
SUPABASE_JWT_SECRET=[SUPABASE-JWT-SECRET]
JWT_SECRET=[SUPABASE-JWT-SECRET]
GOOGLE_STT_KEY=./config/gcp-service-account-key.json
GOOGLE_PROJECT_ID=[GCP-PROJECT-ID]
GEMINI_KEY=[GEMINI-API-KEY]
```

## ✅ Verify

```bash
cd backend
npm run check-env
```

## 📚 Full Guides

- **Quick Start:** `QUICK_START_ENV.md`
- **Detailed Setup:** `SUPABASE_JWT_SETUP.md`
- **All Credentials:** `CREDENTIALS_GUIDE.md`
- **File Location:** `ENV_FILE_PATH.md`
