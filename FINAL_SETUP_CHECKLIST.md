# Final Setup Checklist

Use this checklist to ensure everything is configured correctly before mobile testing.

## ✅ Backend Configuration

### .env File
- [ ] File created at: `backend/.env`
- [ ] `PORT=8080`
- [ ] `DATABASE_URL` - PostgreSQL connection string from Supabase
- [ ] `SUPABASE_URL` - From Supabase Dashboard → Settings → API
- [ ] `SUPABASE_SERVICE_ROLE_KEY` - service_role key from Supabase
- [ ] `SUPABASE_JWT_SECRET` - JWT Secret from Supabase Dashboard
- [ ] `JWT_SECRET` - Same value as SUPABASE_JWT_SECRET
- [ ] `GOOGLE_STT_KEY` - Path to GCP service account JSON (or use direct credentials)
- [ ] `GOOGLE_PROJECT_ID` - Your GCP project ID
- [ ] `GEMINI_KEY` - Gemini API key

### Verification
- [ ] Run `npm run check-env` - All ✅
- [ ] Run `npm start` - Server starts without errors
- [ ] Test: `curl http://localhost:8080/api/health` - Returns JSON

### Database
- [ ] Schema applied in Supabase (from your SQL scripts)
- [ ] Tables exist: `profiles`, `complaints`, `resolutions`, `upvotes`
- [ ] RLS policies enabled

### Storage
- [ ] Bucket `complaint-images` exists
- [ ] Bucket `complaint-audio` exists
- [ ] Bucket `resolution-images` exists
- [ ] Buckets are accessible (public or service_role can upload)

---

## ✅ Frontend Configuration

### API Endpoint
- [ ] File: `frontend/lib/services/api_service.dart`
- [ ] Line 6: Updated with your computer's IP
- [ ] Format: `http://192.168.1.100:8080/api`
- [ ] Port is 8080 (not 3000)

### Android Permissions
- [ ] File: `frontend/android/app/src/main/AndroidManifest.xml`
- [ ] Internet permission declared
- [ ] Camera permission declared
- [ ] Microphone permission declared
- [ ] Location permissions declared
- [ ] `usesCleartextTraffic="true"` set

### Dependencies
- [ ] Run `flutter pub get` - No errors
- [ ] All packages installed

---

## ✅ Build & Install

### APK Build
- [ ] Run `flutter build apk --release` - Success
- [ ] APK file exists: `frontend/build/app/outputs/flutter-apk/app-release.apk`

### Device Setup
- [ ] USB Debugging enabled on device
- [ ] Device connected: `adb devices` shows device
- [ ] APK installed: `adb install app-release.apk` - Success

---

## ✅ Network Configuration

### IP Address
- [ ] Found your computer's IP address
- [ ] IP address in `api_service.dart` matches your IP
- [ ] Device and computer on same WiFi network

### Firewall
- [ ] Port 8080 allowed in firewall
- [ ] Can access from device browser: `http://YOUR_IP:8080/api/health`

### Backend Accessibility
- [ ] Backend running: `npm start`
- [ ] Health endpoint works locally: `http://localhost:8080/api/health`
- [ ] Health endpoint works from device: `http://YOUR_IP:8080/api/health`

---

## ✅ Testing Readiness

### App Launch
- [ ] App opens without crashing
- [ ] Splash screen appears
- [ ] Role selection screen loads

### Basic Functions
- [ ] Can create account
- [ ] Can login
- [ ] Dashboard loads
- [ ] Can navigate between screens

### Critical Functions
- [ ] Camera permission works
- [ ] GPS permission works
- [ ] Can take photo
- [ ] Can get GPS coordinates
- [ ] Can submit complaint
- [ ] Complaint appears in dashboard

---

## 🎯 Ready to Test!

If all above are checked, you're ready for comprehensive testing!

**Start with:** `STEP_BY_STEP_MOBILE_TEST.md`

**For issues:** See troubleshooting in `COMPLETE_MOBILE_TESTING_GUIDE.md`
