# 🚀 CiviX - Start Here

Complete guide to get your CiviX app running and tested on mobile.

## 📍 File Locations

- **Backend .env:** `backend/.env`
- **Frontend API config:** `frontend/lib/services/api_service.dart`
- **APK output:** `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## ⚡ Quick Start (15 minutes)

### 1. Backend Setup (5 min)

```bash
cd backend

# Create .env file
# Copy from env.example and fill in:
# - DATABASE_URL (from Supabase)
# - SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (from Supabase Dashboard → Settings → API)
# - SUPABASE_JWT_SECRET (from Supabase Dashboard → Settings → API → JWT Secret)
# - JWT_SECRET (same as SUPABASE_JWT_SECRET)
# - GEMINI_KEY (from https://makersuite.google.com/app/apikey)
# - GOOGLE_STT_KEY, GOOGLE_PROJECT_ID (from Google Cloud)

npm run check-env  # Verify configuration
npm start          # Start server on port 8080
```

**Get your computer's IP:**
```powershell
ipconfig
# Note: IPv4 Address (e.g., 192.168.1.100)
```

### 2. Frontend Setup (2 min)

**Edit:** `frontend/lib/services/api_service.dart`

**Line 6:** Change to your IP:
```dart
static const String baseUrl = 'http://192.168.1.100:8080/api';
```

### 3. Build APK (3 min)

```bash
cd frontend
flutter pub get
flutter build apk --release
```

### 4. Install on Device (2 min)

```bash
# Enable USB Debugging on device first
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 5. Test (3 min)

1. Open app
2. Create account
3. Lodge complaint (photo + GPS required)
4. Verify it appears in dashboard

---

## 📚 Detailed Guides

### Environment Setup
- **Quick:** `QUICK_START_ENV.md` - 5-minute setup
- **Detailed:** `SUPABASE_JWT_SETUP.md` - Complete credential guide
- **File Location:** `ENV_FILE_PATH.md` - Where to create .env

### Mobile Testing
- **Quick:** `MOBILE_TESTING_QUICK_START.md` - Fast testing
- **Step-by-Step:** `STEP_BY_STEP_MOBILE_TEST.md` - Detailed walkthrough
- **Complete:** `COMPLETE_MOBILE_TESTING_GUIDE.md` - Full guide
- **Workflow:** `TESTING_WORKFLOW.md` - Testing workflow

### Code Verification
- **Environment Variables:** `backend/CODE_ENV_VERIFICATION.md` - All env vars verified
- **Schema Updates:** `SUPABASE_SCHEMA_INTEGRATION.md` - Database schema alignment

---

## ✅ Verification Checklist

### Backend
- [ ] `.env` file created in `backend/` folder
- [ ] All required variables filled in
- [ ] `npm run check-env` shows all ✅
- [ ] Server starts: `npm start`
- [ ] Health check works: `http://localhost:8080/api/health`

### Frontend
- [ ] API endpoint updated in `api_service.dart` with your IP
- [ ] Android permissions configured
- [ ] Dependencies installed: `flutter pub get`
- [ ] APK built: `flutter build apk --release`

### Device
- [ ] USB Debugging enabled
- [ ] Device connected: `adb devices`
- [ ] APK installed: `adb install app-release.apk`
- [ ] App opens successfully

### Testing
- [ ] Can create account
- [ ] Can lodge complaint (photo + GPS)
- [ ] Complaint appears in dashboard
- [ ] Can view complaint details
- [ ] GPS coordinates open Google Maps

---

## 🐛 Common Issues

**Can't connect to backend?**
→ Check IP in `api_service.dart`, verify firewall allows port 8080

**Permissions not working?**
→ Settings → Apps → CiviX → Permissions → Enable all

**Photos not uploading?**
→ Check `SUPABASE_SERVICE_ROLE_KEY` in `.env`, verify buckets exist

**See troubleshooting sections in the detailed guides above.**

---

## 🎯 Next Steps

1. ✅ Complete backend setup
2. ✅ Configure frontend API endpoint
3. ✅ Build and install APK
4. ✅ Test all features
5. ✅ Deploy to production (when ready)

**All code is verified to use .env variables correctly!**

**Happy Testing! 🚀**
