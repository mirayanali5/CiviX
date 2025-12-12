# Complete Testing Workflow

End-to-end guide from setup to mobile testing.

## Phase 1: Backend Verification (5 minutes)

### 1.1 Create .env File

**Location:** `backend/.env`

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

### 1.2 Verify Configuration

```bash
cd backend
npm run check-env
```

### 1.3 Start Server

```bash
npm start
```

### 1.4 Test Health Endpoint

```bash
curl http://localhost:8080/api/health
```

Should return: `{"status":"ok","message":"CiviX API Server is running"}`

### 1.5 Get Your IP Address

**Windows:**
```powershell
ipconfig
# Note the IPv4 Address (e.g., 192.168.1.100)
```

**Mac/Linux:**
```bash
ifconfig | grep "inet "
# Note the IP address
```

---

## Phase 2: Frontend Configuration (2 minutes)

### 2.1 Update API Endpoint

**File:** `frontend/lib/services/api_service.dart`

**Line 3-4:** Change to your IP:
```dart
static const String baseUrl = 'http://192.168.1.100:8080/api';
// Replace 192.168.1.100 with YOUR computer's IP
```

### 2.2 Verify Android Permissions

**File:** `frontend/android/app/src/main/AndroidManifest.xml`

Ensure `android:usesCleartextTraffic="true"` is set in `<application>` tag.

---

## Phase 3: Build APK (3 minutes)

### 3.1 Install Dependencies

```bash
cd frontend
flutter pub get
```

### 3.2 Build Release APK

```bash
flutter build apk --release
```

**Output location:**
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

---

## Phase 4: Install on Device (2 minutes)

### 4.1 Enable USB Debugging

1. Settings → About Phone
2. Tap "Build Number" 7 times
3. Settings → Developer Options
4. Enable "USB Debugging"

### 4.2 Connect & Install

```bash
# Verify device connected
adb devices

# Install APK
adb install frontend/build/app/outputs/flutter-apk/app-release.apk
```

---

## Phase 5: Testing (10 minutes)

### Test Flow:

1. **Launch App** → Should show splash screen → Role selection
2. **Create Account** → Fill form → Submit → Should redirect to dashboard
3. **Lodge Complaint:**
   - Take photo (camera permission)
   - Get GPS (location permission)
   - Enter description OR record audio
   - Submit → Should show success
4. **View Complaint** → Tap complaint → Should show details
5. **Test GPS Link** → Tap coordinates → Should open Google Maps
6. **Upvote** → Tap upvote → Count should increase

### Expected Results:

- ✅ All permissions requested and granted
- ✅ Photos upload successfully
- ✅ GPS coordinates captured
- ✅ Complaints appear in dashboard
- ✅ Backend receives requests (check server logs)

---

## Phase 6: Troubleshooting

### Backend Not Accessible?

1. **Test from device browser:**
   ```
   http://YOUR_IP:8080/api/health
   ```
   Should return JSON. If not, check firewall.

2. **Check firewall:**
   - Windows: Allow port 8080 in Windows Firewall
   - Mac: System Preferences → Security → Firewall

3. **Verify same network:**
   - Device and computer must be on same WiFi

### App Crashes?

1. **Check logs:**
   ```bash
   adb logcat | grep flutter
   ```

2. **Check permissions:**
   - Settings → Apps → CiviX → Permissions
   - Enable Camera, Microphone, Location

### Photos Not Uploading?

1. **Check Supabase:**
   - Verify buckets exist
   - Check `SUPABASE_SERVICE_ROLE_KEY` in `.env`

2. **Check backend logs:**
   - Look for upload errors

---

## Quick Commands Reference

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
```

---

## Success Criteria

✅ Backend runs without errors
✅ Health endpoint responds
✅ APK installs on device
✅ App opens and shows role selection
✅ Can create account
✅ Can lodge complaint with photo + GPS
✅ Complaint appears in dashboard
✅ Can view complaint details
✅ GPS coordinates open Google Maps

**If all above work, your setup is complete! 🎉**
