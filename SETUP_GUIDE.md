# CiviX Setup Guide

Complete setup instructions for the CiviX application.

## Prerequisites

- Node.js (v16 or higher)
- Flutter SDK (latest stable)
- PostgreSQL database (or Supabase account)
- Google Cloud account (for Speech-to-Text, Translation, Gemini)
- Supabase account (for file storage)
- Google Maps API key

## Step 1: Backend Setup

### 1.1 Install Dependencies

```bash
cd backend
npm install
```

### 1.2 Configure Environment

Create `.env` file in `backend/` directory:

```env
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/civix
# OR use Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-supabase-anon-key
SUPABASE_SERVICE_KEY=your-supabase-service-key

# JWT
JWT_SECRET=your-secret-key-change-in-production

# Google Cloud
GOOGLE_CLOUD_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json

# Gemini API
GEMINI_API_KEY=your-gemini-api-key
```

### 1.3 Set Up Database

1. Create PostgreSQL database or use Supabase
2. Run the schema:
   ```bash
   psql -U your_user -d your_database -f database/schema.sql
   ```
   Or paste `database/schema.sql` in Supabase SQL Editor

### 1.4 Set Up Supabase Storage

1. Create a storage bucket named `civix-media`
2. Set public access if needed
3. Add folders: `complaints/photos`, `complaints/audio`, `resolutions`

### 1.5 Create Authority Users

Use SQL or backend API to create authority users:

```sql
INSERT INTO users (id, name, email, password_hash, role, department, account_type)
VALUES (
  'auth_001',
  'Sanitation Officer',
  'sanitation@ghmc.gov.in',
  '$2b$10$...', -- Hash password with bcrypt
  'authority',
  'GHMC Sanitation',
  'public'
);
```

### 1.6 Start Backend Server

```bash
npm start
# or for development with auto-reload
npm run dev
```

Backend should be running on `http://localhost:3000`

## Step 2: Frontend Setup

### 2.1 Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2.2 Configure API Endpoint

Edit `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:3000/api';
// For Android emulator, use: http://10.0.2.2:3000/api
// For iOS simulator, use: http://localhost:3000/api
// For physical device, use your computer's IP: http://192.168.x.x:3000/api
```

### 2.3 Configure Google Maps

#### Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
</application>
```

#### iOS

Edit `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### 2.4 Configure Permissions

#### Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS

Edit `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos of complaints</string>
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record audio descriptions</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to tag complaint locations</string>
```

### 2.5 Run the App

```bash
flutter run
```

## Step 3: Google Cloud Setup

### 3.1 Enable APIs

Enable these APIs in Google Cloud Console:
- Cloud Speech-to-Text API
- Cloud Translation API
- Generative AI API (Gemini)

### 3.2 Create Service Account

1. Go to IAM & Admin > Service Accounts
2. Create new service account
3. Download JSON key
4. Set `GOOGLE_APPLICATION_CREDENTIALS` in `.env` to path of this file

### 3.3 Get Gemini API Key

1. Go to Google AI Studio
2. Create API key
3. Add to `.env` as `GEMINI_API_KEY`

## Step 4: Testing

### Test Backend

```bash
# Health check
curl http://localhost:3000/api/health

# Test signup
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123","account_type":"private"}'
```

### Test Frontend

1. Launch app
2. Select "Citizen" role
3. Create account
4. Try lodging a complaint (requires camera and GPS permissions)

## Troubleshooting

### Backend Issues

- **Database connection error**: Check `DATABASE_URL` in `.env`
- **Supabase upload fails**: Verify `SUPABASE_SERVICE_KEY` and bucket permissions
- **Audio transcription fails**: Check Google Cloud credentials and API enablement
- **Gemini classification fails**: Verify `GEMINI_API_KEY`

### Frontend Issues

- **API connection error**: Check `baseUrl` in `api_service.dart` matches backend
- **Maps not loading**: Verify Google Maps API key is set correctly
- **Permissions denied**: Check Android/iOS permission configurations
- **Build errors**: Run `flutter clean` and `flutter pub get`

## Next Steps

1. Deploy backend to cloud (Heroku, Railway, etc.)
2. Deploy frontend (build APK/IPA or use app stores)
3. Set up production database
4. Configure production environment variables
5. Set up monitoring and logging

## Support

For issues or questions, refer to:
- Backend README: `backend/README.md`
- Frontend README: `frontend/README.md`
- Database README: `backend/database/README.md`
