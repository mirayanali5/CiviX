# Final Mobile Testing Guide

Complete guide with GPS requirement and permission flow.

## 🎯 Key Changes

### GPS Requirement
- ✅ **App will NOT start without GPS enabled**
- ✅ Shows blocking screen if GPS is off
- ✅ Prompts user to enable GPS
- ✅ Continuously checks until GPS is enabled

### Permission Flow
- ✅ **All permissions requested on first launch**
- ✅ Permission screen appears after splash
- ✅ Location permission is **required** (app blocks without it)
- ✅ Camera/Microphone are optional but recommended

## 📱 App Launch Flow

```
1. Splash Screen (2 seconds)
   ↓
2. Permission Screen
   ├─ GPS Check
   │  ├─ GPS OFF → Blocking screen (cannot proceed)
   │  └─ GPS ON → Request permissions
   ├─ Request Location (Required)
   ├─ Request Camera (Optional)
   ├─ Request Microphone (Optional)
   └─ Continue button (only when Location granted)
   ↓
3. Role Selection Screen
   ↓
4. Rest of app...
```

## 🚀 Testing Steps

### Step 1: Backend Setup

```bash
cd backend
# Create .env with all your credentials
npm run check-env
npm start
```

**Get your IP:**
```powershell
ipconfig
# Note: IPv4 Address
```

### Step 2: Frontend Configuration

**Edit:** `frontend/lib/services/api_service.dart`
```dart
static const String baseUrl = 'http://YOUR_IP:8080/api';
```

### Step 3: Build APK

```bash
cd frontend
flutter pub get
flutter build apk --release
```

### Step 4: Install on Device

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Step 5: Test Permission Flow

#### Test 5.1: GPS Off (Blocking)
1. **Turn off GPS** on device
2. Launch app
3. ✅ Should show splash screen
4. ✅ Should show "GPS Required" blocking screen
5. ✅ App should NOT proceed
6. Tap "Enable GPS in Settings"
7. Enable GPS in device settings
8. Return to app
9. ✅ Should automatically detect GPS and proceed

#### Test 5.2: GPS On, Permissions
1. **GPS is ON**
2. Launch app
3. ✅ Should show permission screen
4. ✅ Should request:
   - Location (Required) ✅
   - Camera (Optional)
   - Microphone (Optional)
5. Grant Location permission
6. ✅ "Continue to App" button appears
7. Tap continue
8. ✅ Should proceed to Role Selection

#### Test 5.3: Lodge Complaint
1. Navigate to "New Complaint"
2. ✅ Camera permission requested (if not granted)
3. ✅ Location permission checked
4. ✅ GPS must be enabled
5. If GPS off → Dialog appears
6. Enable GPS → Can proceed
7. Take photo + Get GPS
8. Submit complaint
9. ✅ Should work successfully

## ✅ Expected Behavior

### First Launch (GPS Off)
- Splash → Permission Screen → GPS Required screen
- Cannot proceed until GPS enabled
- "Enable GPS in Settings" button opens settings

### First Launch (GPS On)
- Splash → Permission Screen → Permission requests
- Location permission required
- Camera/Mic optional
- Continue button when location granted

### Subsequent Launches
- If GPS off → Still blocks (GPS always required)
- If GPS on + permissions granted → Quick check, proceed
- If GPS on + permission denied → Request again

## 🐛 Troubleshooting

### App Stuck on Permission Screen

**Check:**
1. GPS is enabled on device
2. Location permission is granted
3. Check app logs: `adb logcat | grep flutter`

### GPS Prompt Not Appearing

**Check:**
1. GPS is actually off
2. Permission screen is loading
3. Check logs for errors

### Permissions Not Requesting

**Check:**
1. AndroidManifest.xml has all permissions
2. App has permission_handler package
3. Device Android version supports runtime permissions

## 📋 Testing Checklist

- [ ] App shows GPS required screen when GPS is off
- [ ] Cannot proceed without GPS enabled
- [ ] "Enable GPS" button opens settings
- [ ] App detects when GPS is enabled
- [ ] Permission screen requests all permissions
- [ ] Location permission is required
- [ ] Cannot proceed without location permission
- [ ] Camera permission requested (optional)
- [ ] Microphone permission requested (optional)
- [ ] "Continue" button appears when location granted
- [ ] App proceeds to Role Selection after permissions

## 🎉 Success Criteria

Your permission flow is working if:

- ✅ App blocks when GPS is off
- ✅ Shows clear prompt to enable GPS
- ✅ Requests all permissions on first launch
- ✅ Location permission is mandatory
- ✅ App proceeds only when GPS + Location permission granted
- ✅ Can lodge complaints successfully

**All code is updated and ready for testing!**
