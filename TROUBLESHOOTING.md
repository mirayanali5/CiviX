# Troubleshooting: App Not Opening

## App not in app drawer / “Installing” but not visible (Huawei / multi-user)

If `flutter run` says “Installing... Success” but the app doesn’t appear on your phone or in the app drawer:

1. **Install for main user** – On devices with multiple users (e.g. Huawei), the app may install to another profile. Run:
   ```bash
   cd frontend
   flutter run --device-user 0
   ```
   Or install the built APK for user 0:
   ```bash
   adb install -r -t --user 0 build\app\outputs\flutter-apk\app-debug.apk
   ```

2. **Huawei: enable app drawer** – If the app is installed but you don’t see it:
   - **Settings → Home screen & wallpaper → Home screen style** → choose **Drawer**, then swipe up on the home screen to open the app drawer and find **CiviX**.
   - Or go to **Settings → Apps → Apps** and open **CiviX** from there.

3. **Launch from PC** (to confirm it’s installed):
   ```bash
   adb shell am start -n com.civix.civix/.MainActivity
   ```

---

If your app installs but doesn't open, follow these steps:

## 1. Check Logs (Most Important)

### Android (using ADB):
```bash
# Connect your phone via USB with USB debugging enabled
adb logcat | grep -i "flutter\|civix\|error\|exception"
```

### Or use Flutter logs:
```bash
flutter logs
```

Look for:
- `❌ Fatal error:` - This will show what's crashing
- `⚠️ Failed to load .env file` - Environment variables not loading
- `⚠️ Supabase initialization error` - Supabase config issue

## 2. Verify .env File

Make sure `frontend/.env` exists and has correct values:

```bash
cd frontend
cat .env
```

Should contain:
- `SUPABASE_URL=...`
- `SUPABASE_ANON_KEY=...`
- `API_BASE_URL=...`
- `OAUTH_REDIRECT_URL=...`

## 3. Rebuild with Clean

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --debug  # Try debug first to see errors
```

## 4. Test on Emulator First

```bash
flutter run
```

This will show errors in the console.

## 5. Common Issues

### Issue: App crashes immediately
**Solution**: Check logs for the exact error. Common causes:
- Missing `.env` file
- Invalid Supabase keys
- Permission issues

### Issue: App shows splash screen then closes
**Solution**: 
- Check if GPS is enabled on device
- Check permission screen logs
- Try granting all permissions manually

### Issue: Black screen
**Solution**:
- Check if MaterialApp is rendering
- Verify theme configuration
- Check for widget build errors

## 6. Quick Fix: Disable Supabase Temporarily

If Supabase is causing issues, you can temporarily disable it:

1. Edit `frontend/lib/main.dart`
2. Comment out the Supabase initialization block
3. Rebuild

## 7. Check Device Compatibility

- Android: Minimum SDK 21 (Android 5.0)
- Check device storage space
- Check if device has required permissions enabled

## 8. Reinstall App

```bash
# Uninstall first
adb uninstall com.example.civix  # Replace with your package name

# Then reinstall
flutter install
```

## 9. Check Build Configuration

Verify `android/app/build.gradle`:
- `minSdkVersion` is set correctly
- Dependencies are resolved
- No conflicting packages

## 10. Test Minimal Version

Create a minimal test app to verify basic Flutter setup works:

```dart
void main() {
  runApp(MaterialApp(home: Scaffold(body: Text('Test'))));
}
```

If this works, the issue is in your app code. If not, it's a Flutter/environment issue.

## Still Not Working?

1. Share the error logs from `adb logcat` or `flutter logs`
2. Share your `.env` file (remove sensitive keys)
3. Share your `pubspec.yaml` dependencies
4. Share device info (Android version, model)
