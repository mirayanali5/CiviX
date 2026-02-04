# Environment Variables Setup

## Overview
The Flutter app now reads configuration from a `.env` file in the `frontend` directory. This file should be synced with values from `backend/.env`.

## Initial Setup

1. **Copy `.env.example` to `.env`**:
   ```bash
   cd frontend
   cp .env.example .env
   ```

2. **Update `.env` with values from `backend/.env`**:
   - `SUPABASE_URL` - Copy from `backend/.env`
   - `SUPABASE_ANON_KEY` - Copy from `backend/.env`
   - `API_BASE_URL` - Set to your backend API URL
   - `OAUTH_REDIRECT_URL` - Keep as `civix://login-callback` (or update if needed)

## Syncing Values

When you update `backend/.env`, make sure to also update `frontend/.env` with the corresponding values:

### From backend/.env to frontend/.env:
- `SUPABASE_URL` → `SUPABASE_URL`
- `SUPABASE_ANON_KEY` → `SUPABASE_ANON_KEY`

### Other frontend/.env values:
- `API_BASE_URL` - Your backend API endpoint (can be different from backend URL)
- `OAUTH_REDIRECT_URL` - OAuth callback URL for mobile app

## Important Notes

1. **`.env` is gitignored** - Never commit `.env` files with real keys
2. **`.env.example` is committed** - This serves as a template
3. **Values are loaded at app startup** - Changes require app restart
4. **Fallback values** - If `.env` is missing, the app uses hardcoded fallbacks

## Current Values (from backend/.env)

- `SUPABASE_URL`: `https://nwzpytaofgjhshefvkvo.supabase.co`
- `SUPABASE_ANON_KEY`: (see backend/.env line 9)

## Troubleshooting

If the app fails to load environment variables:
1. Check that `.env` exists in `frontend/` directory
2. Verify file format (no spaces around `=`)
3. Check console logs for loading errors
4. Ensure `flutter_dotenv` package is installed (`flutter pub get`)
