# Mobile Testing Quick Start Guide

Fastest way to test CiviX on your Android device.

## ⚡ 5-Minute Setup

### Step 1: Backend Setup (2 min)

```bash
cd backend

# 1. Create .env file (if not exists)
# Copy from env.example and fill in values

# 2. Verify configuration
npm run check-env

# 3. Start server
npm start
```

**Note your computer's IP address:**
```powershell
ipconfig
# Look for IPv4 Address (e.g., 192.168.1.100)
```

### Step 2: Frontend Configuration (1 min)

**Edit:** `frontend/lib/services/api_service.dart`

**Change:**
```dart
static const String baseUrl = 'http://YOUR_IP:8080/api';
// Example: http://192.168.1.100:8080/api
```

### Step 3: Build APK (2 min)

```bash
cd frontend
flutter pub get
flutter build apk --release
```

### Step 4: Install on Device

```bash
# Connect device via USB
adb install build/app/outputs/flutter-apk/app-release.apk
```

## ✅ Test Checklist

1. [ ] App opens
2. [ ] Can create account
3. [ ] Can lodge complaint (photo + GPS required)
4. [ ] Complaint appears in dashboard
5. [ ] Can view complaint details
6. [ ] GPS coordinates open Google Maps

## 🐛 Common Issues

**Can't connect to backend?**
- Check IP address in `api_service.dart`
- Verify backend is running: `curl http://YOUR_IP:8080/api/health`
- Check firewall allows port 8080

**Permissions not working?**
- Settings → Apps → CiviX → Permissions → Enable all

**See `MOBILE_TESTING_GUIDE.md` for detailed troubleshooting.**
