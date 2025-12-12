# CiviX Quick Start Guide

Get up and running quickly with CiviX.

## Backend Setup (5 minutes)

1. **Install dependencies:**
```bash
cd backend
npm install
```

2. **Create .env file:**
```bash
cp .env.example .env
```

3. **Generate JWT secret:**
```bash
npm run generate-jwt
# Copy the output to your .env file
```

4. **Fill in .env with your credentials:**
   - Database URL (PostgreSQL or Supabase)
   - Supabase credentials (for file storage)
   - Gemini API key (for AI classification)
   - Google Cloud credentials (for audio transcription)

5. **Check configuration:**
```bash
npm run check-env
```

6. **Set up database:**
   - Run `database/schema.sql` in your PostgreSQL/Supabase database

7. **Start server:**
```bash
npm start
```

Server runs on `http://localhost:3000`

## Frontend Setup (5 minutes)

1. **Install dependencies:**
```bash
cd frontend
flutter pub get
```

2. **Update API endpoint:**
   - Edit `lib/services/api_service.dart`
   - Set `baseUrl` to your backend URL
   - For mobile: Use your computer's IP address (e.g., `http://192.168.1.100:3000/api`)

3. **Configure Google Maps (optional):**
   - Add API key to `android/app/src/main/AndroidManifest.xml`

4. **Run app:**
```bash
flutter run
```

## Build APK for Testing

1. **Build APK:**
```bash
cd frontend
flutter build apk --release
```

2. **Find APK:**
   - Location: `frontend/build/app/outputs/flutter-apk/app-release.apk`

3. **Install on device:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Testing Checklist

- [ ] Backend server starts without errors
- [ ] Database connection works
- [ ] Can create citizen account
- [ ] Can login
- [ ] Can lodge complaint (photo + GPS)
- [ ] Can view complaints
- [ ] Can upvote complaints
- [ ] Authority can login
- [ ] Authority can resolve complaints

## Common Issues

**Backend won't start:**
- Check all required .env variables are set
- Run `npm run check-env` to verify

**App can't connect:**
- Verify backend is running
- Check IP address in `api_service.dart`
- Ensure device/emulator can reach backend

**Permissions denied:**
- Check AndroidManifest.xml has all permissions
- Grant permissions manually in device settings

## Next Steps

- See `APK_TESTING_GUIDE.md` for detailed testing instructions
- See `SETUP_GUIDE.md` for comprehensive setup
- See `README.md` for feature documentation
