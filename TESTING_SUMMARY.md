# CiviX Testing Summary

Complete guide for testing your CiviX app with APK on mobile device.

## ✅ What's Been Done

### Backend Configuration
- ✅ All API keys now read from `.env` file
- ✅ Environment validation script created
- ✅ Comprehensive `.env.example` with all variables
- ✅ Better error messages for missing configurations

### Files Created/Updated
1. `backend/env.example` - Template for all environment variables
2. `backend/config/validateEnv.js` - Validation script
3. `backend/ENV_SETUP.md` - Detailed environment setup guide
4. `APK_TESTING_GUIDE.md` - Complete APK testing instructions
5. `QUICK_START.md` - Fast setup guide

## 🎯 Testing Workflow

### Phase 1: Backend Setup (10 minutes)

1. **Configure Environment**
   ```bash
   cd backend
   cp env.example .env
   # Edit .env with your actual values
   ```

2. **Validate Configuration**
   ```bash
   npm run validate-env
   ```
   Should show: ✅ All required variables configured

3. **Start Backend**
   ```bash
   npm start
   ```
   Should show: ✅ Configured for all services

4. **Test Backend**
   - Open browser: `http://localhost:3000/api/health`
   - Should return: `{"status":"ok","message":"CiviX API Server is running"}`

### Phase 2: Mobile Configuration (5 minutes)

1. **Find Your IP Address**
   ```powershell
   # Windows
   ipconfig
   ```
   Note your IPv4 address (e.g., `192.168.1.100`)

2. **Update Flutter App**
   - Edit `frontend/lib/services/api_service.dart`
   - Change: `static const String baseUrl = 'http://YOUR_IP:3000/api';`

3. **Test Backend from Phone**
   - Connect phone to same WiFi as computer
   - Open browser on phone
   - Go to: `http://YOUR_IP:3000/api/health`
   - Should see: `{"status":"ok"}`

### Phase 3: Build APK (5 minutes)

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

APK Location: `frontend/build/app/outputs/flutter-apk/app-release.apk`

### Phase 4: Install & Test (10 minutes)

**Install via USB:**
```bash
adb install frontend/build/app/outputs/flutter-apk/app-release.apk
```

**Or manually:**
1. Transfer APK to phone (email/cloud)
2. Open APK file
3. Allow installation
4. Install

## 📋 Testing Checklist

### Basic Functionality
- [ ] App launches
- [ ] Splash screen → Role selection
- [ ] Can create citizen account
- [ ] Can login
- [ ] Dashboard loads
- [ ] Can lodge complaint (photo + GPS)
- [ ] Complaint submits successfully

### Advanced Features
- [ ] Audio recording works
- [ ] Map view shows complaints
- [ ] GPS coordinates open Google Maps
- [ ] Upvote functionality works
- [ ] Authority login works
- [ ] Resolution upload works

### Network & Permissions
- [ ] Backend connection works
- [ ] Camera permission granted
- [ ] GPS permission granted
- [ ] Microphone permission (if used)
- [ ] Error handling works

## 🔧 Environment Variables Reference

### Critical (Required)
```env
DATABASE_URL=postgresql://user:pass@host:5432/db
JWT_SECRET=your-secret-key-min-32-chars
```

### Important (Required for full functionality)
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-key
GEMINI_API_KEY=your-gemini-key
```

### Optional (For audio features)
```env
GOOGLE_CLOUD_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=./path/to/key.json
```

## 🐛 Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| Can't connect to backend | Check IP address, same WiFi, firewall |
| Camera not working | Grant permission in phone settings |
| GPS not working | Enable location permission, test outdoors |
| APK won't install | Enable "Unknown Sources" in settings |
| Backend validation fails | Run `npm run validate-env` to see missing vars |

## 📱 Testing on Multiple Devices

1. **Build APK once** - works on all Android devices
2. **Test on different Android versions** (if possible)
3. **Test on different screen sizes**
4. **Test with/without internet** (error handling)

## 🚀 Production Checklist

Before deploying:

- [ ] All environment variables set
- [ ] Backend deployed to cloud
- [ ] Update app with production API URL
- [ ] Remove `usesCleartextTraffic` from AndroidManifest
- [ ] Set proper CORS origins
- [ ] Use HTTPS for all API calls
- [ ] Test thoroughly on real devices

## 📚 Documentation Reference

- **Quick Start**: `QUICK_START.md`
- **Full Setup**: `SETUP_GUIDE.md`
- **APK Testing**: `APK_TESTING_GUIDE.md`
- **Environment Setup**: `backend/ENV_SETUP.md`
- **Backend README**: `backend/README.md`

## 🎓 Next Steps After Testing

1. **Fix any bugs** found during testing
2. **Optimize performance** if needed
3. **Add analytics** for production
4. **Set up error reporting** (Sentry, etc.)
5. **Prepare for Play Store** submission
6. **Build app bundle**: `flutter build appbundle --release`

---

**Ready to test?** Start with `QUICK_START.md` for the fastest path!
