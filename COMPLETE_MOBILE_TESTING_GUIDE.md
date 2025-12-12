# Complete Mobile Testing Guide

Everything you need to test CiviX on your Android device.

## 📍 Quick Reference

- **Backend .env location:** `backend/.env`
- **Frontend API config:** `frontend/lib/services/api_service.dart` (line 6)
- **APK output:** `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## Part A: Backend Configuration

### A1: Create .env File

**Path:** `C:\Users\miray\OneDrive\Desktop\CiviX Local\backend\.env`

**Content:**
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

### A2: Get Supabase JWT Secret

1. **Supabase Dashboard** → Your Project → **Settings** → **API**
2. Scroll to **"JWT Secret"**
3. **Copy the entire secret string**
4. Paste in both `SUPABASE_JWT_SECRET` and `JWT_SECRET` in `.env`

### A3: Verify & Start

```bash
cd backend
npm run check-env  # Should show all ✅
npm start          # Server starts on port 8080
```

### A4: Get Your IP Address

**Windows:**
```powershell
ipconfig
# Note: IPv4 Address (e.g., 192.168.1.100)
```

---

## Part B: Frontend Configuration

### B1: Update API Endpoint

**File:** `frontend/lib/services/api_service.dart`

**Line 6:** Change to:
```dart
static const String baseUrl = 'http://192.168.1.100:8080/api';
// Replace 192.168.1.100 with YOUR computer's IP from A4
```

### B2: Verify Android Permissions

**File:** `frontend/android/app/src/main/AndroidManifest.xml`

✅ Already updated with:
- Internet permission
- Camera permission
- Microphone permission
- Location permissions
- `usesCleartextTraffic="true"` (for HTTP)

---

## Part C: Build APK

### C1: Install Dependencies

```bash
cd frontend
flutter pub get
```

### C2: Build Release APK

```bash
flutter build apk --release
```

**Output:** `frontend/build/app/outputs/flutter-apk/app-release.apk`

**Build time:** 2-3 minutes

---

## Part D: Install on Device

### D1: Enable USB Debugging

**On Android device:**
1. Settings → About Phone
2. Tap "Build Number" **7 times**
3. Settings → Developer Options
4. Enable **"USB Debugging"**

### D2: Connect & Install

```bash
# Verify connection
adb devices
# Should show your device

# Install APK
adb install frontend/build/app/outputs/flutter-apk/app-release.apk
```

**Success message:** `Success`

---

## Part E: Testing Workflow

### E1: Initial Launch Test

1. Open CiviX app
2. ✅ Should show splash screen
3. ✅ Auto-navigates to Role Selection
4. ✅ Shows "Citizen" and "Authority" options

### E2: Account Creation Test

1. Tap "Citizen" → "Create Account"
2. Fill form:
   - Name: "Test User"
   - Email: "test@example.com"
   - Password: "password123"
   - Account Type: "Private"
3. Submit
4. ✅ Should redirect to Dashboard
5. ✅ Should show stats (Open: 0, Resolved: 0, Total: 0)

### E3: Lodge Complaint Test (CRITICAL)

**This is the most important test!**

1. Tap **"New Complaint"**
2. **Camera:**
   - ✅ Permission requested
   - ✅ Tap "Allow"
   - ✅ Tap "Take Photo"
   - ✅ Take photo
   - ✅ Photo appears in preview
3. **GPS:**
   - ✅ Permission requested
   - ✅ Tap "Allow"
   - ✅ Tap "Get Location"
   - ✅ Coordinates appear (e.g., "17.3850, 78.4867")
4. **Description:**
   - Type: "Garbage pile on main road"
5. **Submit:**
   - ✅ Button enabled (photo + GPS present)
   - ✅ Tap "Submit Complaint"
   - ✅ Shows loading indicator
   - ✅ Shows "Complaint submitted successfully!"
   - ✅ Redirects to Dashboard
   - ✅ Complaint appears in list

**Backend should show:**
```
POST /api/complaints - 201 Created
```

**Supabase Storage should show:**
- Photo in `complaint-images` bucket

**Database should show:**
- New row in `complaints` table

### E4: View Complaint Details

1. Tap complaint card
2. ✅ Shows full image
3. ✅ Shows description
4. ✅ Shows GPS coordinates (clickable)
5. ✅ Shows status: "open"
6. ✅ Shows department (auto-assigned)
7. ✅ Shows upvote count

### E5: GPS to Maps Test

1. In complaint details, tap GPS coordinates
2. ✅ Opens Google Maps (or browser)
3. ✅ Shows correct location

### E6: Upvote Test

1. In complaint details, tap upvote button
2. ✅ Count increases
3. ✅ Shows "Upvoted!" message

### E7: Map View Test

1. From dashboard, tap map icon
2. ✅ Map loads
3. ✅ Shows markers for complaints
4. ✅ Can tap markers
5. ✅ Can view complaint details

---

## Part F: Verification Checklist

### Backend Verification

- [ ] Server running on port 8080
- [ ] Health endpoint works: `http://localhost:8080/api/health`
- [ ] Can access from device browser: `http://YOUR_IP:8080/api/health`
- [ ] Server logs show API requests
- [ ] No errors in backend console

### Database Verification

- [ ] Complaints appear in Supabase `complaints` table
- [ ] User profiles appear in `profiles` table
- [ ] Upvotes appear in `upvotes` table

### Storage Verification

- [ ] Photos in `complaint-images` bucket
- [ ] Audio files in `complaint-audio` bucket (if used)
- [ ] Resolution images in `resolution-images` bucket (if used)

### App Verification

- [ ] App opens without crashing
- [ ] All permissions work
- [ ] Can create account
- [ ] Can lodge complaint
- [ ] Can view complaints
- [ ] Can upvote
- [ ] GPS opens maps
- [ ] Map view works

---

## Part G: Troubleshooting

### G1: Can't Connect to Backend

**Symptoms:**
- "Connection failed" error
- Loading spinner never stops

**Fix:**
1. Verify backend running: `npm start` in backend folder
2. Test from device browser: `http://YOUR_IP:8080/api/health`
3. If browser can't connect:
   ```powershell
   # Windows Firewall - Allow port 8080
   New-NetFirewallRule -DisplayName "CiviX Backend" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
   ```
4. Verify IP address in `api_service.dart` matches your computer's IP
5. Ensure device and computer on same WiFi

### G2: Permissions Not Working

**Fix:**
1. Settings → Apps → CiviX → Permissions
2. Manually enable:
   - Camera
   - Microphone
   - Location
3. Uninstall and reinstall if needed:
   ```bash
   adb uninstall com.civix.civix
   adb install app-release.apk
   ```

### G3: Photos Not Uploading

**Fix:**
1. Check `SUPABASE_SERVICE_ROLE_KEY` in `.env`
2. Verify buckets exist in Supabase:
   - `complaint-images`
   - `complaint-audio`
   - `resolution-images`
3. Check backend logs for upload errors
4. Verify bucket permissions (should allow service_role)

### G4: Audio Transcription Fails

**Fix:**
1. Check `GOOGLE_STT_KEY` path is correct
2. Verify file exists: `backend/config/gcp-service-account-key.json`
3. Or verify `GOOGLE_CLIENT_EMAIL` and `GOOGLE_PRIVATE_KEY` are set
4. Check `GOOGLE_PROJECT_ID` is set
5. Verify APIs enabled in GCP Console:
   - Speech-to-Text API
   - Translation API

### G5: Department Classification Fails

**Fix:**
1. Check `GEMINI_KEY` in `.env`
2. Verify API key is valid
3. Falls back to keyword matching if Gemini fails (this is OK)

---

## Part H: Testing Different Scenarios

### Scenario 1: Guest Complaint (No Login)

1. Don't login
2. Try to lodge complaint
3. ✅ Should work (creates with guest_id)
4. ✅ Cannot upvote (guests can't upvote)

### Scenario 2: Duplicate Complaint

1. Lodge complaint at location A
2. Lodge another complaint at same location (within 250m)
3. ✅ Should detect duplicate
4. ✅ Shows duplicate modal
5. ✅ Auto-upvotes if logged in

### Scenario 3: Audio Recording

1. Lodge complaint
2. Instead of typing description, record audio
3. ✅ Should transcribe audio
4. ✅ Uses transcript as description
5. ✅ Stores both raw and translated transcripts

### Scenario 4: Authority Resolution

1. Login as authority
2. View department complaints
3. Tap complaint
4. Upload resolution photos
5. Add notes
6. Mark as resolved
7. ✅ Status changes to "resolved"
8. ✅ Photos in `resolution-images` bucket

---

## Part I: Monitoring & Debugging

### View Backend Logs

```bash
cd backend
npm start
# Watch console for:
# - API requests
# - Errors
# - Upload status
```

### View App Logs

```bash
# Real-time logs
adb logcat | grep flutter

# Filter by package
adb logcat | grep com.civix.civix

# Clear logs and start fresh
adb logcat -c
adb logcat | grep flutter
```

### Test Backend from Device

**Use device browser or REST client:**
```
GET http://YOUR_IP:8080/api/health
GET http://YOUR_IP:8080/api/complaints
```

---

## Part J: Success Indicators

### ✅ Backend Working

- Server starts without errors
- Health endpoint responds
- API requests appear in logs
- Database queries succeed
- File uploads work

### ✅ Frontend Working

- App opens
- Permissions requested
- Can create account
- Can lodge complaint
- Data syncs with backend

### ✅ Integration Working

- Complaints appear in database
- Photos upload to Supabase
- GPS coordinates saved
- Department auto-assigned
- Duplicate detection works

---

## Quick Command Reference

```bash
# Backend
cd backend
npm run check-env    # Verify .env
npm start            # Start server

# Frontend
cd frontend
flutter pub get      # Install deps
flutter build apk --release  # Build APK

# Device
adb devices          # Check connection
adb install app-release.apk  # Install
adb logcat | grep flutter  # View logs
adb uninstall com.civix.civix  # Uninstall

# Testing
curl http://localhost:8080/api/health  # Test backend
curl http://YOUR_IP:8080/api/health     # Test from network
```

---

## 📚 Documentation Files

- **Quick Start:** `MOBILE_TESTING_QUICK_START.md`
- **Step-by-Step:** `STEP_BY_STEP_MOBILE_TEST.md`
- **Detailed Guide:** `backend/MOBILE_TESTING_GUIDE.md`
- **Testing Workflow:** `TESTING_WORKFLOW.md`
- **Environment Setup:** `SUPABASE_JWT_SETUP.md`

---

## 🎯 Final Checklist

Before considering testing complete:

- [ ] Backend runs on port 8080
- [ ] All .env variables configured
- [ ] Backend accessible from device
- [ ] APK built and installed
- [ ] App opens successfully
- [ ] Can create account
- [ ] Can lodge complaint (photo + GPS)
- [ ] Complaint appears in dashboard
- [ ] Can view complaint details
- [ ] GPS opens Google Maps
- [ ] Can upvote complaints
- [ ] Map view works
- [ ] Authority login works (if tested)
- [ ] Resolution works (if tested)

**If all checked, your app is ready! 🚀**
