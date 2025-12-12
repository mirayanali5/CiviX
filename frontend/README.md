# CiviX Flutter Frontend

Flutter mobile application for the CiviX civic complaint system.

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure API endpoint:
   - Update `lib/services/api_service.dart` with your backend URL
   - Change `baseUrl` from `http://localhost:3000/api` to your actual backend URL

3. Configure Google Maps:
   - Add your Google Maps API key to:
     - `android/app/src/main/AndroidManifest.xml`
     - `ios/Runner/AppDelegate.swift`

4. Run the app:
```bash
flutter run
```

## Features

### Citizen Interface
- ✅ Splash Screen
- ✅ Role Selection
- ✅ Login/Signup (with account type selection)
- ✅ Dashboard with stats and complaint list
- ✅ Map view of all complaints
- ✅ Lodge Complaint (photo + GPS mandatory)
- ✅ Complaint Details with upvote
- ✅ Profile with permissions

### Authority Interface
- ✅ Authority Login
- ✅ Dashboard with department stats
- ✅ Department-specific map view
- ✅ Complaint Resolution (with photo upload)
- ✅ Resolution History
- ✅ Authority Profile

## Permissions Required

- Camera (for photos)
- Microphone (for audio recording)
- Location/GPS (for coordinates)

## API Integration

The app connects to the backend API at the URL specified in `api_service.dart`. Make sure the backend is running and accessible.

## Notes

- Anonymous complaints are supported (no login required)
- GPS coordinates are mandatory for all complaints
- Photo is mandatory for all complaints
- Either description or audio recording is required
- Duplicate detection happens automatically on the backend
- Google Maps integration for viewing locations
