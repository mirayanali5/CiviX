# .env File Location

## 📍 Where to Create/Paste Your .env File

Your `.env` file should be located in the `backend` folder:

```
CiviX Local/
└── backend/
    └── .env          ← CREATE THIS FILE HERE
```

## 🔍 Full Path Examples

### Windows:
```
C:\Users\miray\OneDrive\Desktop\CiviX Local\backend\.env
```

### Mac/Linux:
```
/Users/yourname/Desktop/CiviX Local/backend/.env
```

## 📝 Quick Setup

1. **Navigate to backend folder:**
   ```bash
   cd backend
   ```

2. **Create .env file:**
   ```bash
   # Windows PowerShell
   New-Item -Path .env -ItemType File
   
   # Mac/Linux
   touch .env
   ```

3. **Open .env file** in a text editor

4. **Paste your configuration** (see `SUPABASE_JWT_SETUP.md` for template)

## ✅ Verify File Location

After creating the file, verify it exists:

```bash
cd backend
ls -la .env    # Mac/Linux
dir .env       # Windows
```

You should see the `.env` file listed.

## 🔐 What to Paste in .env

See `SUPABASE_JWT_SETUP.md` for the complete template and where to get each value.

**Key values you need:**
- `SUPABASE_URL` - From Supabase Dashboard → Settings → API
- `SUPABASE_SERVICE_ROLE_KEY` - From Supabase Dashboard → Settings → API
- `SUPABASE_JWT_SECRET` - From Supabase Dashboard → Settings → API → JWT Secret
- `JWT_SECRET` - Use the SAME value as SUPABASE_JWT_SECRET
- `DATABASE_URL` - From Supabase Dashboard → Settings → Database
- `GEMINI_KEY` - From https://makersuite.google.com/app/apikey
- `GOOGLE_STT_KEY` - Path to your GCP service account JSON file
- `GOOGLE_PROJECT_ID` - Your GCP project ID

## ⚠️ Important

- **Never commit `.env` to Git** - It contains secrets!
- **File name must be exactly `.env`** (with the dot at the start)
- **No file extension** - Just `.env`, not `.env.txt`
