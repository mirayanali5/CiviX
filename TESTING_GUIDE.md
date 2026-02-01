# Testing Guide - Running Backend and Frontend for Mobile Testing

This guide will help you run both the backend server and Flutter frontend to test all functionality from your mobile device.

## Prerequisites

1. **Node.js** installed (v14 or higher)
2. **Flutter** installed and configured
3. **Android Studio** or **Xcode** for mobile development
4. **PostgreSQL/Supabase** database configured
5. **Google Cloud** credentials configured for Speech-to-Text and Translation
6. **Supabase** storage buckets configured:
   - `complaint-audio`
   - `complaint-images`
   - `resolution-images`

## Step 1: Configure Backend Environment Variables

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a `.env` file (if not exists) with all required variables:
   ```env
   # Database
   DATABASE_URL=your_postgresql_connection_string
   
   # Supabase
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_anon_key
   
   # Google Cloud (Speech-to-Text & Translation)
   GOOGLE_APPLICATION_CREDENTIALS=path/to/your/service-account-key.json
   # OR use individual credentials:
   GOOGLE_CLIENT_EMAIL=your-service-account-email@project.iam.gserviceaccount.com
   GOOGLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   GOOGLE_PROJECT_ID=your-project-id
   
   # Gemini AI
   GEMINI_API_KEY=your_gemini_api_key
   
   # JWT
   JWT_SECRET=your_jwt_secret_key
   
   # Google Maps (optional)
   GOOGLE_MAPS=your_google_maps_api_key
   
   # Server
   PORT=8080
   NODE_ENV=development
   ```

3. Validate environment variables:
   ```bash
   npm run validate-env
   ```

## Step 2: Start Backend Server

1. Install dependencies (first time only):
   ```bash
   npm install
   ```

2. Start the backend server:
   ```bash
   npm start
   ```
   
   Or for development with auto-reload:
   ```bash
   npm run dev
   ```

3. Verify backend is running:
   - Check console output for: `✅ Server is ready to accept connections!`
   - Test health endpoint: Open browser to `http://localhost:8080/api/health`
   - You should see: `{ "status": "ok" }`

4. **Important**: Note your computer's IP address:
   - **Windows**: Open Command Prompt and run `ipconfig`, look for "IPv4 Address"
   - **Mac/Linux**: Run `ifconfig` or `ip addr`, look for your local network IP
   - Example: `192.168.1.100` or `10.0.0.5`

## Step 3: Configure Frontend API Base URL

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Open `lib/services/api_service.dart` and check the base URL:
   ```dart
   static const String baseUrl = 'http://YOUR_COMPUTER_IP:8080/api';
   ```

3. Replace `YOUR_COMPUTER_IP` with your actual IP address from Step 2:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:8080/api';
   ```

   **Important**: 
   - Use your computer's local network IP, NOT `localhost` or `127.0.0.1`
   - Both your computer and mobile device must be on the same Wi-Fi network
   - If testing on emulator, you can use `10.0.2.2:8080` for Android emulator

## Step 4: Build and Install Flutter App on Mobile

### Option A: Using Android Device (APK)

1. Connect your Android device via USB and enable USB debugging

2. Build debug APK:
   ```bash
   cd frontend
   flutter build apk --debug
   ```

3. Install on device:
   ```bash
   flutter install
   ```
   
   Or manually install:
   - APK location: `frontend/build/app/outputs/flutter-apk/app-debug.apk`
   - Transfer to phone and install

### Option B: Using Android Emulator

1. Start Android emulator from Android Studio

2. Run Flutter app:
   ```bash
   cd frontend
   flutter run
   ```

### Option C: Using iOS Device/Simulator

1. For iOS Simulator:
   ```bash
   cd frontend
   flutter run
   ```

2. For physical iOS device:
   - Connect device via USB
   - Trust computer on device
   - Run: `flutter run`

## Step 5: Configure Firewall (If Backend Not Accessible)

If your mobile device can't connect to the backend:

### Windows:
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Add Node.js or allow port 8080

Or run in PowerShell (as Administrator):
```powershell
New-NetFirewallRule -DisplayName "CiviX Backend" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

### Mac:
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/node
```

### Linux:
```bash
sudo ufw allow 8080/tcp
```

## Step 6: Test Functionality

### 1. Test Backend Connection
- Open the app on your mobile device
- Check if you can login/signup
- If connection fails, verify:
  - Backend is running (`http://localhost:8080/api/health`)
  - IP address in `api_service.dart` is correct
  - Firewall allows port 8080
  - Both devices on same network

### 2. Test Citizen Features
- **Splash Screen**: App should request permissions (GPS, Camera, Microphone)
- **GPS Check**: App should not start without GPS enabled
- **Signup/Login**: Create account or login
- **Dashboard**: View all complaints
- **Lodge Complaint**: 
  - Take photo (mandatory)
  - Record audio OR enter description
  - GPS coordinates should auto-fill
  - Submit and see success popup
- **Map View**: See complaints as markers on map
- **Upvote**: Tap upvote on complaints

### 3. Test Authority Features
- **Login**: Login with authority account
- **Dashboard**: See department-specific complaints
- **Map View**: See department complaints on map
- **Resolve Complaint**:
  - Tap on a complaint
  - Add resolution photos (at least 1 required)
  - Add notes
  - Submit resolution
- **History**: View resolved complaints

### 4. Test Audio Features
- Record audio complaint
- Verify transcription appears
- Check if translation works (for non-English)

## Troubleshooting

### Backend Issues

**Problem**: Backend won't start
- Check if port 8080 is already in use: `netstat -ano | findstr :8080` (Windows) or `lsof -i :8080` (Mac/Linux)
- Verify all environment variables are set correctly
- Check database connection

**Problem**: "Database connection failed"
- Verify `DATABASE_URL` is correct
- Check PostgreSQL is running
- Test connection manually

**Problem**: "Supabase not configured"
- Verify `SUPABASE_URL` and `SUPABASE_KEY` are set
- Check Supabase project is active

**Problem**: "Google Cloud credentials not configured"
- Verify `GOOGLE_APPLICATION_CREDENTIALS` path is correct
- Or set `GOOGLE_CLIENT_EMAIL` and `GOOGLE_PRIVATE_KEY`
- Check service account has Speech-to-Text and Translation APIs enabled

### Frontend Issues

**Problem**: "Connection refused" or "Network error"
- Verify backend is running
- Check IP address in `api_service.dart` matches your computer's IP
- Ensure both devices on same Wi-Fi network
- Check firewall settings

**Problem**: "GPS not working"
- Enable GPS on device
- Grant location permissions
- Check `AndroidManifest.xml` has location permissions

**Problem**: "Camera/Microphone not working"
- Grant permissions when prompted
- Check app settings for permissions
- Restart app after granting permissions

**Problem**: "Audio transcription fails"
- Check backend logs for Google Cloud errors
- Verify Google Cloud credentials are correct
- Check Speech-to-Text API is enabled in Google Cloud Console
- Verify audio file format (M4A should work)

**Problem**: "Maps not showing"
- Verify `GOOGLE_MAPS` API key is set in backend `.env`
- Check `AndroidManifest.xml` has Google Maps API key
- Verify Google Maps API is enabled in Google Cloud Console

### Mobile-Specific Issues

**Problem**: APK won't install
- Enable "Install from Unknown Sources" in Android settings
- Check if device architecture matches APK (arm64-v8a, armeabi-v7a, x86_64)

**Problem**: App crashes on startup
- Check Flutter logs: `flutter logs`
- Verify all permissions are granted
- Check if GPS is enabled (app requires GPS to start)

## Quick Test Checklist

- [ ] Backend server running on port 8080
- [ ] Backend health check returns `{ "status": "ok" }`
- [ ] Frontend `api_service.dart` has correct IP address
- [ ] Mobile device and computer on same Wi-Fi network
- [ ] Firewall allows port 8080
- [ ] App installed on mobile device
- [ ] GPS enabled on mobile device
- [ ] Permissions granted (Camera, Microphone, Location)
- [ ] Can login/signup
- [ ] Can view complaints on dashboard
- [ ] Can lodge new complaint with photo
- [ ] Can record audio complaint
- [ ] Can view complaints on map
- [ ] Authority can see department complaints
- [ ] Authority can resolve complaints

## Development Tips

1. **Backend Logs**: Keep backend terminal open to see API requests and errors
2. **Flutter Logs**: Use `flutter logs` to see app logs
3. **Network Debugging**: Use browser DevTools Network tab or Postman to test API endpoints
4. **Hot Reload**: Use `flutter run` for hot reload during development
5. **Backend Auto-reload**: Use `npm run dev` for automatic backend restart on changes

## Production Deployment

For production:
1. Use HTTPS instead of HTTP
2. Set proper CORS headers
3. Use environment-specific `.env` files
4. Build release APK: `flutter build apk --release`
5. Deploy backend to cloud (Heroku, AWS, etc.)
6. Update `api_service.dart` with production URL
