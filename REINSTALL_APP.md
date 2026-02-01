# Reinstall CiviX app on your phone

Follow these steps to build and install the app again.

---

## Option A: Install via USB (recommended)

**1. Connect your phone to the PC**
- Use a USB cable.
- On the phone: enable **USB debugging** (Settings → Developer options → USB debugging). If you don’t see Developer options, enable it first: Settings → About phone → tap “Build number” 7 times.

**2. Allow USB debugging**
- When you connect, the phone may ask “Allow USB debugging?” → tap **Allow**.

**3. Open a terminal on your PC**
- Open Command Prompt or PowerShell.
- Go to the frontend folder:
  ```bash
  cd "C:\Users\miray\OneDrive\Desktop\CiviX Local\frontend"
  ```

**4. Get dependencies**
  ```bash
  flutter pub get
  ```

**5. Install the app on the connected phone**
  ```bash
  flutter run
  ```
  (Use `flutter run` to build and install in one step. Do not use `flutter install` alone—it requires an existing release APK.)
  Flutter will build and install the app on the device. Wait until it says “Installing…” then “Success”.

**6. Disconnect and open CiviX**
- Unplug the phone and open the **CiviX** app from the app drawer.

---

## Option B: Build APK and install manually

Use this if you don’t want to use USB or want to share the APK.

**1. Open terminal and go to frontend**
  ```bash
  cd "C:\Users\miray\OneDrive\Desktop\CiviX Local\frontend"
  ```

**2. Get dependencies**
  ```bash
  flutter pub get
  ```

**3. Build a debug APK**
  ```bash
  flutter build apk --debug
  ```
  Wait until the build finishes (can take a few minutes).

**4. Find the APK**
  - Path:
    ```
    C:\Users\miray\OneDrive\Desktop\CiviX Local\frontend\build\app\outputs\flutter-apk\app-debug.apk
    ```

**5. Copy APK to your phone**
  - **USB:** Connect phone, copy `app-debug.apk` to the phone’s Download folder (or any folder).
  - **Other:** Email it to yourself, use Google Drive, or any file-sharing method, then download it on the phone.

**6. Install on the phone**
  - Open **Files** (or your file manager) on the phone.
  - Go to the folder where you put `app-debug.apk`.
  - Tap `app-debug.apk`.
  - If asked “Install from unknown sources?” → enable it for Files (or Chrome) in Settings, then tap the APK again.
  - Tap **Install** and then **Open**.

---

## After installing

1. **Same Wi‑Fi:** Phone and PC on the same Wi‑Fi (PC IP: 192.168.0.101).
2. **Backend running:** In a terminal: `cd backend` then `npm start`.
3. **Open the app:** Grant location, camera, and microphone when asked.
4. **Login:** Use your credentials (see YOUR_LOGIN_CREDENTIALS.md).

---

## If something goes wrong

| Problem | What to do |
|--------|------------|
| “No devices found” (Option A) | Check USB cable, enable USB debugging, tap Allow on the phone. Run `flutter devices` to see if the phone is listed. |
| Build fails | Run `flutter clean`, then `flutter pub get`, then try again. |
| “Install blocked” / “Unknown sources” | Allow installation from your file manager or browser in Settings → Security (or Apps). |
| App crashes on open | Ensure backend is running and baseUrl in `api_service.dart` is `http://192.168.0.101:8080/api`. |
