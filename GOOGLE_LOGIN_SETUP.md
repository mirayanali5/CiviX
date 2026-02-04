# Google Login Setup Guide

## Overview
Google login has been added for **citizens only**. Citizens can now choose between:
1. Email/Password login (existing)
2. Google login (new)

## Setup Steps

### 1. Get Supabase Anon Key
1. Go to https://app.supabase.com
2. Select your project (`nwzpytaofgjhshefvkvo`)
3. Navigate to **Settings > API**
4. Copy the **"anon public"** key (NOT the service_role key)
5. Open `frontend/lib/config/supabase_config.dart`
6. Replace `YOUR_SUPABASE_ANON_KEY_HERE` with your actual anon key

### 2. Configure Google OAuth in Supabase
1. In Supabase dashboard, go to **Authentication > Providers**
2. Enable **Google** provider
3. You'll need to create a Google OAuth app:
   - Go to https://console.cloud.google.com
   - Create a new project or select existing
   - Enable Google+ API
   - Create OAuth 2.0 credentials
   - Add authorized redirect URIs:
     - `https://nwzpytaofgjhshefvkvo.supabase.co/auth/v1/callback`
   - Copy Client ID and Client Secret
4. Paste Client ID and Client Secret into Supabase Google provider settings

### 3. Configure Redirect URLs
1. In Supabase dashboard, go to **Authentication > URL Configuration**
2. Add to **Redirect URLs**:
   - `civix://login-callback` (for mobile app)
   - Your production URL if deploying

### 4. Configure Deep Links (Mobile)

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="civix" android:host="login-callback" />
</intent-filter>
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>civix</string>
        </array>
    </dict>
</array>
```

### 5. Install Dependencies
Run in the `frontend` directory:
```bash
flutter pub get
```

## Backend Configuration
The backend route `/auth/login/google` is already set up. Make sure:
- `SUPABASE_URL` is set in `backend/.env`
- `SUPABASE_SERVICE_ROLE_KEY` is set in `backend/.env`
- `JWT_SECRET` matches `SUPABASE_JWT_SECRET` (they should be the same)

## Testing
1. Run the Flutter app
2. Go to Citizen Login screen
3. You should see:
   - Email/Password form (existing)
   - "OR" divider
   - "Continue with Google" button
4. Tap Google button to test OAuth flow

## Notes
- Google login is **only available for citizens**
- Authority accounts continue to use email/password login only
- Users logging in with Google will have their profile automatically created/updated in the `profiles` table
- Account type defaults to `'public'` for Google-based citizen accounts
