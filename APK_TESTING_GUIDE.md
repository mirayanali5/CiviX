# CiviX APK Testing Guide

Complete guide to build and test the CiviX Flutter app as an APK on your Android device.

## Prerequisites

1. **Flutter SDK** installed and configured
2. **Android Studio** installed
3. **Android device** (physical device recommended) or emulator
4. **Backend server** running and accessible
5. **USB Debugging** enabled on your Android device

## Step 1: Configure Backend for Mobile Access

### 1.1 Update Backend .env

Make sure your backend `.env` file has all required variables (see `backend/.env.example`):

```env
PORT=3000
DATABASE_URL=your-database-url
SUPABASE_URL=your-supabase-url
SUPABASE_SERVICE_KEY=your-service-key
JWT_SECRET=your-jwt-secret
GEMINI_API_KEY=your-gemini-key
GOOGLE_CLOUD_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=path/to/key.json
```

### 1.2 Find Your Computer's IP Address

**Windows:**
```powershell
ipconfig
# Look for IPv4 Address under your active network adapter
# Example: 192.168.1.100
```

**Mac/Linux:**
```bash
ifconfig
# or
ip addr show
# Look for inet address (usually starts with 192.168.x.x or 10.0.x.x)
```

### 1.3 Start Backend Server

```bash
cd backend
npm start
```

The server should be running on `http://localhost:3000`

### 1.4 Configure Firewall (if needed)

Allow incoming connections on port 3000:
- **Windows**: Windows Defender Firewall > Allow an app through firewall
- **Mac**: System Preferences > Security & Privacy > Firewall

## Step 2: Configure Flutter App for Mobile

### 2.1 Update API Endpoint

Edit `frontend/lib/services/api_service.dart`:

```dart
class ApiService {
  // Replace with your computer's IP address
  // Format: http://YOUR_IP_ADDRESS:3000/api
  static const String baseUrl = 'http://192.168.1.100:3000/api';
  // Example: http://192.168.1.100:3000/api
  
  // For emulator, use:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // ...
}
```

**Important:** Replace `192.168.1.100` with your actual computer IP address.

### 2.2 Configure Android Permissions

The permissions should already be configured, but verify `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application
        android:usesCleartextTraffic="true"
        ...>
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

**Note:** `android:usesCleartextTraffic="true"` allows HTTP connections (needed for local testing).

### 2.3 Configure Google Maps (Optional but Recommended)

Edit `android/app/src/main/AndroidManifest.xml` and add your Google Maps API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

## Step 3: Build APK

### 3.1 Navigate to Frontend Directory

```bash
cd frontend
```

### 3.2 Clean Previous Builds (Optional)

```bash
flutter clean
flutter pub get
```

### 3.3 Build APK

**Debug APK (for testing):**
```bash
flutter build apk --debug
```

**Release APK (optimized, for distribution):**
```bash
flutter build apk --release
```

The APK will be generated at:
- Debug: `frontend/build/app/outputs/flutter-apk/app-debug.apk`
- Release: `frontend/build/app/outputs/flutter-apk/app-release.apk`

### 3.4 Build Split APKs (Optional - Smaller file size)

For smaller APK files (one per architecture):
```bash
flutter build apk --split-per-abi
```

This creates separate APKs for:
- `app-armeabi-v7a-release.apk` (32-bit)
- `app-arm64-v8a-release.apk` (64-bit)
- `app-x86_64-release.apk` (x86_64)

## Step 4: Install APK on Device

### Method 1: USB Transfer

1. Connect your Android device via USB
2. Enable **USB Debugging** on your device:
   - Settings > About Phone > Tap "Build Number" 7 times
   - Settings > Developer Options > Enable USB Debugging
3. Copy the APK file to your device
4. On your device, open the APK file and install

### Method 2: ADB Install (Recommended)

```bash
# Make sure device is connected and USB debugging is enabled
adb devices
# Should show your device

# Install APK
adb install frontend/build/app/outputs/flutter-apk/app-release.apk

# Or for debug APK
adb install frontend/build/app/outputs/flutter-apk/app-debug.apk
```

### Method 3: Wireless ADB (Advanced)

```bash
# Connect via USB first
adb tcpip 5555
# Disconnect USB

# Connect wirelessly (replace IP with your device IP)
adb connect DEVICE_IP:5555

# Install APK
adb install app-release.apk
```

## Step 5: Testing Checklist

### 5.1 Initial Setup Test

- [ ] App launches successfully
- [ ] Splash screen appears
- [ ] Role selection screen loads
- [ ] Can navigate between Citizen and Authority options

### 5.2 Citizen Flow Test

- [ ] **Signup:**
  - [ ] Can create new account
  - [ ] Account type selection works (Private/Public)
  - [ ] Successfully redirects to dashboard after signup

- [ ] **Login:**
  - [ ] Can login with existing credentials
  - [ ] Error handling for wrong credentials

- [ ] **Dashboard:**
  - [ ] Stats cards display correctly
  - [ ] Complaint list loads
  - [ ] Can search complaints
  - [ ] Can navigate to map view
  - [ ] Can navigate to profile

- [ ] **Lodge Complaint:**
  - [ ] Camera permission requested and works
  - [ ] GPS permission requested and works
  - [ ] Can take photo
  - [ ] Can get GPS coordinates
  - [ ] Can enter description
  - [ ] Can record audio (if microphone permission granted)
  - [ ] Submit button disabled until photo + GPS are present
  - [ ] Complaint submits successfully
  - [ ] Duplicate detection works (if applicable)

- [ ] **Complaint Details:**
  - [ ] Can view complaint details
  - [ ] Can upvote complaint
  - [ ] GPS coordinates open Google Maps
  - [ ] Images load correctly

- [ ] **Map View:**
  - [ ] Map loads with markers
  - [ ] Can see complaint locations
  - [ ] Can tap markers to view details

- [ ] **Profile:**
  - [ ] User info displays correctly
  - [ ] Permissions status shows correctly
  - [ ] Can logout

### 5.3 Authority Flow Test

- [ ] **Authority Login:**
  - [ ] Can login with authority credentials
  - [ ] Redirects to authority dashboard

- [ ] **Authority Dashboard:**
  - [ ] Department stats display correctly
  - [ ] Department complaints list loads
  - [ ] Can filter by status

- [ ] **Complaint Resolution:**
  - [ ] Can view complaint details
  - [ ] Can upload resolution photos
  - [ ] Can add notes
  - [ ] Can mark as resolved
  - [ ] Status updates correctly

- [ ] **Resolution History:**
  - [ ] History list loads
  - [ ] Before/after images display

### 5.4 Network Testing

- [ ] **Connection Tests:**
  - [ ] App works on WiFi
  - [ ] App works on mobile data
  - [ ] Error handling when backend is offline
  - [ ] Proper error messages displayed

- [ ] **Backend Connectivity:**
  - [ ] Verify backend is accessible from device
  - [ ] Test with: `http://YOUR_IP:3000/api/health` in device browser

## Step 6: Troubleshooting

### Issue: App can't connect to backend

**Solution:**
1. Verify backend is running: `curl http://localhost:3000/api/health`
2. Check IP address in `api_service.dart` matches your computer's IP
3. Ensure device and computer are on same network
4. Check firewall isn't blocking port 3000
5. Test backend URL in device browser: `http://YOUR_IP:3000/api/health`

### Issue: Camera/GPS permissions not working

**Solution:**
1. Check `AndroidManifest.xml` has permission declarations
2. Manually grant permissions: Settings > Apps > CiviX > Permissions
3. Uninstall and reinstall app to reset permissions

### Issue: Google Maps not loading

**Solution:**
1. Verify Google Maps API key is set in `AndroidManifest.xml`
2. Check API key is enabled for Android apps in Google Cloud Console
3. Verify billing is enabled for Google Maps API

### Issue: APK installation fails

**Solution:**
1. Enable "Install from Unknown Sources" in device settings
2. For Android 8+: Enable "Install unknown apps" for your file manager
3. Try installing via ADB instead

### Issue: App crashes on launch

**Solution:**
1. Check logs: `adb logcat | grep flutter`
2. Verify all dependencies installed: `flutter pub get`
3. Try clean build: `flutter clean && flutter build apk --debug`
4. Check for missing environment variables in backend

### Issue: Images not loading

**Solution:**
1. Verify Supabase storage is configured correctly
2. Check `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` in backend `.env`
3. Verify storage bucket `civix-media` exists in Supabase
4. Check network connectivity

## Step 7: Production Build (Optional)

For a production-ready APK:

```bash
# Generate signing key (first time only)
keytool -genkey -v -keystore ~/civix-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias civix

# Configure signing in android/app/build.gradle
# Then build release APK
flutter build apk --release
```

## Step 8: Testing on Multiple Devices

1. **Different Android versions:** Test on Android 8, 9, 10, 11, 12+
2. **Different screen sizes:** Test on phone and tablet
3. **Different network conditions:** WiFi, 4G, 5G
4. **Different locations:** Test GPS accuracy

## Quick Test Script

Create a test checklist file and check off items as you test:

```bash
# Test backend connectivity from device
curl http://YOUR_IP:3000/api/health

# Monitor app logs
adb logcat | grep -i civix

# Uninstall app
adb uninstall com.civix.civix

# Reinstall app
adb install app-release.apk
```

## Next Steps

After successful testing:

1. **Fix any bugs** found during testing
2. **Optimize performance** if needed
3. **Add analytics** for production
4. **Set up CI/CD** for automated builds
5. **Prepare for Play Store** submission (if applicable)

## Support

If you encounter issues:
1. Check backend logs: `npm start` output
2. Check Flutter logs: `flutter run` or `adb logcat`
3. Verify all environment variables are set
4. Test backend endpoints with Postman/curl
5. Check network connectivity between device and backend

---

**Happy Testing! 🚀**
