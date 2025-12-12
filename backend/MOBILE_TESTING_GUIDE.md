# Complete Mobile Testing Guide for CiviX

Step-by-step guide to build APK and test on your Android device.

## 📋 Prerequisites Checklist

- [ ] Backend server is running and accessible
- [ ] All `.env` variables are configured in `backend/.env`
- [ ] Database schema is set up in Supabase
- [ ] Storage buckets exist: `complaint-images`, `complaint-audio`, `resolution-images`
- [ ] Flutter SDK installed
- [ ] Android device or emulator ready
- [ ] USB debugging enabled on device
- [ ] Device and computer on same WiFi network

---

## Part 1: Backend Setup & Verification

### Step 1: Configure Backend .env File

**File location:** `backend/.env`

**Required variables:**
```env
PORT=8080
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
SUPABASE_URL=https://[PROJECT-REF].supabase.co
SUPABASE_SERVICE_ROLE_KEY=[SERVICE-ROLE-KEY]
SUPABASE_JWT_SECRET=[JWT-SECRET]
JWT_SECRET=[JWT-SECRET]
GOOGLE_STT_KEY=./config/gcp-service-account-key.json
GOOGLE_PROJECT_ID=[GCP-PROJECT-ID]
GEMINI_KEY=[GEMINI-API-KEY]
```

### Step 2: Verify Backend Configuration

```bash
cd backend
npm run check-env
```

**Expected output:**
```
✅ Environment variables validated
```

### Step 3: Start Backend Server

```bash
npm start
```

**Expected output:**
```
🚀 CiviX Backend Server running on port 8080
📝 Environment: development
🗄️  Database: ✅ Configured
☁️  Supabase: ✅ Configured
🤖 Gemini AI: ✅ Configured
🔐 JWT Secret: ✅ Configured
```

### Step 4: Test Backend Health

Open browser or use curl:
```
http://localhost:8080/api/health
```

Should return:
```json
{"status":"ok","message":"CiviX API Server is running"}
```

### Step 5: Find Your Computer's IP Address

**Windows:**
```powershell
ipconfig
# Look for "IPv4 Address" under your active network adapter
# Example: 192.168.1.100
```

**Mac/Linux:**
```bash
ifconfig | grep "inet "
# or
ip addr show
# Look for IP starting with 192.168.x.x or 10.0.x.x
```

**Note this IP address** - you'll need it for the mobile app!

---

## Part 2: Frontend Configuration for Mobile

### Step 1: Update API Endpoint

**File:** `frontend/lib/services/api_service.dart`

**Find this line:**
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**Replace with your computer's IP:**
```dart
static const String baseUrl = 'http://192.168.1.100:8080/api';
// Replace 192.168.1.100 with YOUR computer's IP address
```

**Important:**
- Use port `8080` (not 3000) - matches your backend PORT
- Use your computer's IP address (not localhost)
- Device and computer must be on same WiFi network

### Step 2: Configure Android Permissions

**File:** `frontend/android/app/src/main/AndroidManifest.xml`

**Ensure these permissions exist:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application
        android:usesCleartextTraffic="true"
        ...>
        <!-- Google Maps API Key (optional) -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

**Key points:**
- `android:usesCleartextTraffic="true"` - Allows HTTP connections (needed for local testing)
- All permissions are declared

### Step 3: Install Flutter Dependencies

```bash
cd frontend
flutter pub get
```

---

## Part 3: Build APK

### Option A: Debug APK (Faster, for Testing)

```bash
cd frontend
flutter build apk --debug
```

**APK location:**
```
frontend/build/app/outputs/flutter-apk/app-debug.apk
```

### Option B: Release APK (Optimized)

```bash
cd frontend
flutter build apk --release
```

**APK location:**
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

### Option C: Split APKs (Smaller file size)

```bash
flutter build apk --release --split-per-abi
```

Creates separate APKs for different architectures.

---

## Part 4: Install APK on Device

### Method 1: ADB Install (Recommended)

1. **Enable USB Debugging on device:**
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"

2. **Connect device via USB**

3. **Verify connection:**
   ```bash
   adb devices
   ```
   Should show your device listed.

4. **Install APK:**
   ```bash
   # For debug APK
   adb install frontend/build/app/outputs/flutter-apk/app-debug.apk
   
   # For release APK
   adb install frontend/build/app/outputs/flutter-apk/app-release.apk
   ```

### Method 2: Manual Transfer

1. **Copy APK to device:**
   - Connect device via USB
   - Copy APK file to device storage
   - Or use cloud storage (Google Drive, etc.)

2. **Install on device:**
   - Open file manager on device
   - Navigate to APK location
   - Tap APK file
   - Allow "Install from Unknown Sources" if prompted
   - Tap "Install"

---

## Part 5: Testing Checklist

### Pre-Testing Setup

- [ ] Backend server is running on port 8080
- [ ] Backend health check works: `http://YOUR_IP:8080/api/health`
- [ ] Device and computer on same WiFi network
- [ ] APK installed on device
- [ ] App opens without crashing

### Test 1: Initial App Launch

- [ ] App opens successfully
- [ ] Splash screen shows "CiviX"
- [ ] Automatically navigates to Role Selection
- [ ] Can see "Citizen" and "Authority" options

### Test 2: Citizen Signup & Login

- [ ] Can navigate to Citizen Login
- [ ] "Create Account" button works
- [ ] Can fill signup form:
  - [ ] Name
  - [ ] Email
  - [ ] Password
  - [ ] Account Type (Private/Public)
- [ ] Signup succeeds
- [ ] Redirects to Dashboard after signup
- [ ] Can logout and login again

### Test 3: Lodge Complaint (Critical Test)

- [ ] Navigate to "New Complaint"
- [ ] **Camera permission** requested and granted
- [ ] Can take photo (photo appears in preview)
- [ ] **Location permission** requested and granted
- [ ] GPS coordinates appear (e.g., "17.3850, 78.4867")
- [ ] Can enter description OR record audio
- [ ] **Microphone permission** requested (if recording audio)
- [ ] Can record audio
- [ ] Submit button enabled only when photo + GPS are present
- [ ] Complaint submits successfully
- [ ] Success message appears
- [ ] Redirects to Dashboard
- [ ] Complaint appears in list

### Test 4: View Complaints

- [ ] Dashboard shows complaint list
- [ ] Stats cards display (Open, Resolved, Total)
- [ ] Can see complaint thumbnails
- [ ] Can tap complaint to view details
- [ ] Complaint details show:
  - [ ] Full image
  - [ ] Description
  - [ ] GPS coordinates (clickable)
  - [ ] Status
  - [ ] Department
  - [ ] Upvote count

### Test 5: GPS & Maps Integration

- [ ] Can click GPS coordinates
- [ ] Opens Google Maps (or browser)
- [ ] Shows correct location on map

### Test 6: Upvote

- [ ] Can upvote complaint
- [ ] Upvote count increases
- [ ] Success message appears

### Test 7: Map View

- [ ] Can navigate to Map view
- [ ] Map loads with markers
- [ ] Can see complaint locations
- [ ] Can tap markers to view details

### Test 8: Authority Login

- [ ] Can navigate to Authority Login
- [ ] Can login with authority credentials
- [ ] Redirects to Authority Dashboard
- [ ] Shows department-specific complaints

### Test 9: Authority Resolution

- [ ] Can view complaint details
- [ ] Can upload resolution photos
- [ ] Can add notes
- [ ] Can mark as resolved
- [ ] Status updates to "resolved"

### Test 10: Network Connectivity

- [ ] App works on WiFi
- [ ] App works on mobile data (if backend is accessible)
- [ ] Error message shows if backend is offline
- [ ] App reconnects when network returns

---

## Part 6: Troubleshooting

### Issue: App Can't Connect to Backend

**Symptoms:**
- "Connection failed" error
- Loading spinner never stops
- API calls fail

**Solutions:**

1. **Verify backend is running:**
   ```bash
   curl http://localhost:8080/api/health
   ```

2. **Check IP address in `api_service.dart`:**
   - Must match your computer's IP
   - Must use port 8080
   - Format: `http://192.168.1.100:8080/api`

3. **Test from device browser:**
   - Open browser on device
   - Go to: `http://YOUR_IP:8080/api/health`
   - Should see JSON response
   - If not, check firewall

4. **Check firewall:**
   - Windows: Allow port 8080 in Windows Firewall
   - Mac: System Preferences → Security → Firewall

5. **Verify same network:**
   - Device and computer must be on same WiFi
   - Check WiFi names match

### Issue: Camera/GPS Permissions Not Working

**Solutions:**

1. **Manually grant permissions:**
   - Settings → Apps → CiviX → Permissions
   - Enable Camera, Microphone, Location

2. **Uninstall and reinstall:**
   ```bash
   adb uninstall com.civix.civix
   adb install app-release.apk
   ```

3. **Check AndroidManifest.xml:**
   - Ensure all permissions are declared

### Issue: Photos Not Uploading

**Solutions:**

1. **Check Supabase storage:**
   - Verify buckets exist: `complaint-images`, `complaint-audio`, `resolution-images`
   - Check bucket permissions (should be public or allow service_role)

2. **Check backend logs:**
   - Look for upload errors
   - Verify `SUPABASE_SERVICE_ROLE_KEY` is correct

3. **Check file size:**
   - Default limit is 10MB
   - Try smaller image

### Issue: Audio Transcription Fails

**Solutions:**

1. **Check Google Cloud credentials:**
   - Verify `GOOGLE_STT_KEY` path is correct
   - Or verify `GOOGLE_CLIENT_EMAIL` and `GOOGLE_PRIVATE_KEY` are set
   - Check `GOOGLE_PROJECT_ID` is set

2. **Check APIs are enabled:**
   - Speech-to-Text API
   - Translation API

### Issue: Department Classification Fails

**Solutions:**

1. **Check Gemini API key:**
   - Verify `GEMINI_KEY` is set correctly
   - Test at https://makersuite.google.com/app/apikey

2. **Check backend logs:**
   - Look for Gemini API errors
   - Falls back to keyword matching if Gemini fails

### Issue: Duplicate Detection Not Working

**Solutions:**

1. **Check database:**
   - Verify `haversine` function exists in database
   - Check complaints table has `latitude` and `longitude` columns

2. **Test with same location:**
   - Submit complaint at same GPS coordinates
   - Should detect duplicate

---

## Part 7: Testing with Real Data

### Test Scenarios

1. **Submit complaint with photo + GPS + description**
   - Should create successfully
   - Should appear in dashboard

2. **Submit complaint with photo + GPS + audio**
   - Should transcribe audio
   - Should use transcript as description

3. **Submit duplicate complaint**
   - Same location (within 250m)
   - Similar description
   - Should show duplicate modal
   - Should auto-upvote if logged in

4. **Test as guest (no login)**
   - Can submit complaint
   - Cannot upvote
   - Shows as "Anonymous"

5. **Test authority resolution**
   - Login as authority
   - View department complaints
   - Upload resolution photos
   - Mark as resolved

---

## Part 8: Monitoring & Debugging

### View Backend Logs

```bash
cd backend
npm start
# Watch console for errors
```

### View App Logs on Device

```bash
# Connect device
adb logcat | grep flutter

# Or filter by package
adb logcat | grep com.civix.civix
```

### Test Backend Endpoints from Device

Use a REST client app on your device (like Postman mobile) or browser:

```
GET http://YOUR_IP:8080/api/health
GET http://YOUR_IP:8080/api/complaints
```

---

## Part 9: Production Checklist

Before deploying to production:

- [ ] Change `NODE_ENV=production` in `.env`
- [ ] Use production database URL
- [ ] Use production Supabase project
- [ ] Set strong `JWT_SECRET`
- [ ] Enable HTTPS (backend should use HTTPS in production)
- [ ] Update frontend API URL to production backend
- [ ] Test all features thoroughly
- [ ] Build release APK with signing key

---

## Quick Reference Commands

```bash
# Backend
cd backend
npm run check-env      # Verify .env configuration
npm start              # Start server

# Frontend
cd frontend
flutter pub get        # Install dependencies
flutter build apk --release  # Build APK
adb install app-release.apk   # Install on device

# Testing
curl http://localhost:8080/api/health  # Test backend
adb devices            # Check device connection
adb logcat | grep flutter  # View app logs
```

---

## Support

If you encounter issues:

1. Check backend logs for errors
2. Check app logs: `adb logcat`
3. Verify all `.env` variables are set
4. Test backend endpoints directly
5. Verify network connectivity
6. Check Supabase dashboard for storage issues

**Happy Testing! 🚀**
