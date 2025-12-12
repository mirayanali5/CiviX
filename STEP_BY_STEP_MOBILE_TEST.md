# Step-by-Step Mobile Testing Guide

Complete walkthrough to test CiviX on your Android device.

## 🎯 Goal

Build APK, install on device, and test all features with your backend running locally.

---

## STEP 1: Backend Setup (5 minutes)

### 1.1 Create .env File

**Location:** `backend/.env`

**Create the file:**
```powershell
cd "C:\Users\miray\OneDrive\Desktop\CiviX Local\backend"
New-Item -Path .env -ItemType File
```

**Paste this template and fill in your values:**
```env
PORT=8080
NODE_ENV=development

DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres
SUPABASE_URL=https://[PROJECT-REF].supabase.co
SUPABASE_SERVICE_ROLE_KEY=[SERVICE-ROLE-KEY]
SUPABASE_JWT_SECRET=[JWT-SECRET-FROM-SUPABASE]
JWT_SECRET=[SAME-JWT-SECRET-AS-ABOVE]

GOOGLE_STT_KEY=./config/gcp-service-account-key.json
GOOGLE_PROJECT_ID=[GCP-PROJECT-ID]
GEMINI_KEY=[GEMINI-API-KEY]
```

### 1.2 Get Supabase JWT Secret

1. Go to: https://supabase.com/dashboard
2. Select your project
3. Settings → API
4. Scroll to **"JWT Secret"**
5. **Copy the entire secret**
6. Paste in both `SUPABASE_JWT_SECRET` and `JWT_SECRET` in `.env`

### 1.3 Verify Configuration

```bash
cd backend
npm run check-env
```

**Should show:**
```
✅ Environment variables validated
```

### 1.4 Start Backend

```bash
npm start
```

**Should show:**
```
🚀 CiviX Backend Server running on port 8080
✅ All services configured
```

### 1.5 Test Backend

Open browser: `http://localhost:8080/api/health`

Should return: `{"status":"ok","message":"CiviX API Server is running"}`

### 1.6 Get Your Computer's IP

**Windows PowerShell:**
```powershell
ipconfig
```

**Look for:**
```
IPv4 Address. . . . . . . . . . . : 192.168.1.100
```

**Note this IP!** (Example: 192.168.1.100)

---

## STEP 2: Frontend Configuration (2 minutes)

### 2.1 Update API Endpoint

**File:** `frontend/lib/services/api_service.dart`

**Find line 6-7:**
```dart
static const String baseUrl = 'http://YOUR_IP_ADDRESS:8080/api';
```

**Replace with your actual IP:**
```dart
static const String baseUrl = 'http://192.168.1.100:8080/api';
// Use YOUR computer's IP address from Step 1.6
```

### 2.2 Check Android Permissions

**File:** `frontend/android/app/src/main/AndroidManifest.xml`

**Verify this exists in `<application>` tag:**
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

If missing, add it!

---

## STEP 3: Build APK (3 minutes)

### 3.1 Install Dependencies

```bash
cd frontend
flutter pub get
```

### 3.2 Build Release APK

```bash
flutter build apk --release
```

**Wait for build to complete** (takes 2-3 minutes)

**APK location:**
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

---

## STEP 4: Install on Device (2 minutes)

### 4.1 Enable USB Debugging

**On your Android device:**

1. Settings → About Phone
2. Tap **"Build Number"** 7 times
3. Go back → Settings → **Developer Options**
4. Enable **"USB Debugging"**

### 4.2 Connect Device

1. Connect device to computer via USB
2. On device: Tap **"Allow USB Debugging"** when prompted

### 4.3 Verify Connection

```bash
adb devices
```

**Should show:**
```
List of devices attached
ABC123XYZ    device
```

### 4.4 Install APK

```bash
adb install frontend/build/app/outputs/flutter-apk/app-release.apk
```

**Should show:**
```
Performing Streamed Install
Success
```

---

## STEP 5: Testing (10 minutes)

### Test 1: App Launch ✅

1. Open CiviX app on device
2. Should see splash screen with "CiviX"
3. Automatically goes to Role Selection
4. Should see "Citizen" and "Authority" buttons

**✅ Pass if:** App opens without crashing

---

### Test 2: Create Account ✅

1. Tap **"Citizen"**
2. Tap **"Create Account"**
3. Fill form:
   - Name: "Test User"
   - Email: "test@example.com"
   - Password: "password123"
   - Confirm Password: "password123"
   - Account Type: Select "Private"
4. Tap **"Create Account"**

**Expected:**
- Form validates
- Account created
- Redirects to Dashboard
- Shows stats cards

**✅ Pass if:** Dashboard loads with stats

---

### Test 3: Lodge Complaint (CRITICAL) ✅

1. Tap **"New Complaint"** button
2. **Camera Permission:**
   - Should request camera permission
   - Tap "Allow"
   - Tap "Take Photo"
   - Take a photo
   - Photo should appear in preview
3. **GPS Permission:**
   - Should request location permission
   - Tap "Allow"
   - Tap "Get Location"
   - Should show coordinates (e.g., "17.3850, 78.4867")
4. **Description:**
   - Type: "Test complaint - garbage on road"
5. **Submit:**
   - Tap "Submit Complaint"
   - Should show loading
   - Should show success message
   - Redirects to Dashboard

**Expected:**
- Photo captured ✅
- GPS coordinates captured ✅
- Complaint submitted ✅
- Appears in dashboard ✅

**✅ Pass if:** Complaint appears in dashboard list

---

### Test 4: View Complaint Details ✅

1. Tap on the complaint card
2. Should show:
   - Full image
   - Description
   - GPS coordinates (clickable)
   - Status: "open"
   - Department (auto-assigned)
   - Upvote button

**✅ Pass if:** All details display correctly

---

### Test 5: GPS to Google Maps ✅

1. In complaint details, tap GPS coordinates
2. Should open Google Maps (or browser)
3. Should show location on map

**✅ Pass if:** Maps opens with correct location

---

### Test 6: Upvote ✅

1. In complaint details, tap upvote button
2. Upvote count should increase
3. Should show "Upvoted!" message

**✅ Pass if:** Count increases

---

### Test 7: Map View ✅

1. From dashboard, tap map icon (top right)
2. Map should load
3. Should see markers for complaints
4. Tap marker → Should show info window
5. Tap "Open Details" → Should show complaint

**✅ Pass if:** Map loads with markers

---

## STEP 6: Verify Backend Integration

### Check Backend Logs

**In backend terminal, you should see:**
```
POST /api/complaints - 201 Created
GET /api/complaints - 200 OK
POST /api/complaints/:id/upvote - 200 OK
```

### Check Supabase Storage

1. Go to Supabase Dashboard
2. Storage → Buckets
3. Check `complaint-images` bucket
4. Should see uploaded photos

### Check Database

1. Go to Supabase Dashboard
2. Table Editor → `complaints`
3. Should see your test complaint

---

## STEP 7: Test Authority Flow (Optional)

### 7.1 Authority Login

1. Logout from Citizen account
2. Go to Role Selection
3. Tap "Authority"
4. Login with authority credentials
5. Should see Authority Dashboard

### 7.2 Resolve Complaint

1. Tap on a complaint
2. Upload resolution photo
3. Add notes
4. Tap "Mark as Resolved"
5. Status should change to "resolved"

---

## 🐛 Troubleshooting

### Problem: "Connection failed" or "Network error"

**Solution:**
1. Check backend is running: `npm start` in backend folder
2. Test from device browser: `http://YOUR_IP:8080/api/health`
3. If browser can't connect:
   - Check firewall (allow port 8080)
   - Verify IP address is correct
   - Ensure device and computer on same WiFi

### Problem: Camera/GPS permissions not working

**Solution:**
1. Settings → Apps → CiviX → Permissions
2. Manually enable Camera, Microphone, Location
3. Uninstall and reinstall app if needed

### Problem: Photos not uploading

**Solution:**
1. Check `SUPABASE_SERVICE_ROLE_KEY` in `.env`
2. Verify buckets exist in Supabase
3. Check backend logs for errors

### Problem: App crashes on launch

**Solution:**
1. Check logs: `adb logcat | grep flutter`
2. Verify all dependencies: `flutter pub get`
3. Try clean build: `flutter clean && flutter build apk --release`

---

## ✅ Success Criteria

Your setup is working if:

- ✅ Backend starts without errors
- ✅ Health endpoint responds
- ✅ APK installs on device
- ✅ App opens and shows role selection
- ✅ Can create account
- ✅ Can lodge complaint (photo + GPS)
- ✅ Complaint appears in dashboard
- ✅ Can view complaint details
- ✅ GPS coordinates open Google Maps
- ✅ Can upvote complaints

---

## 📱 Quick Test Script

Run these commands to verify everything:

```bash
# 1. Backend health
curl http://localhost:8080/api/health

# 2. Device connection
adb devices

# 3. Install APK
adb install frontend/build/app/outputs/flutter-apk/app-release.apk

# 4. View logs
adb logcat | grep flutter
```

---

## 🎉 You're Done!

If all tests pass, your CiviX app is fully functional on mobile!

**Next steps:**
- Test with real-world scenarios
- Test on different devices
- Prepare for production deployment

**See `MOBILE_TESTING_GUIDE.md` for detailed troubleshooting.**
