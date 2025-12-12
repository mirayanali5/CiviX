# Permission Flow Implementation

## Overview

The app now enforces GPS requirement and requests all permissions on first launch.

## App Flow

1. **Splash Screen** (2 seconds)
   ↓
2. **Permission Screen** (NEW - Blocks app if GPS off)
   - Checks GPS first
   - If GPS off → Shows prompt, blocks app
   - If GPS on → Requests all permissions
   - Only proceeds when GPS enabled + location permission granted
   ↓
3. **Role Selection Screen**
   ↓
4. Rest of app...

## Permission Screen Behavior

### GPS Check (First Priority)
- ✅ Checks if GPS is enabled
- ❌ If OFF → Shows blocking screen with "Enable GPS" button
- ✅ If ON → Proceeds to request permissions

### Permission Requests
After GPS is enabled:
1. **Location Permission** (Required)
   - Must be granted to proceed
   - App blocks if denied

2. **Camera Permission** (Optional but recommended)
   - Requested but app can continue if denied
   - Will be requested again when needed

3. **Microphone Permission** (Optional)
   - Requested but app can continue if denied
   - Will be requested again when needed

## Key Features

### GPS Enforcement
- App **cannot start** without GPS enabled
- Shows clear prompt with "Open Settings" button
- Continuously checks until GPS is enabled

### Permission Status Display
- Shows which permissions are granted
- Visual indicators (green checkmark / red X)
- "Continue" button only appears when location is granted

### Re-check Functionality
- "I've enabled GPS" button to re-check
- Auto-navigates when GPS is enabled

## Files Updated

- ✅ `frontend/lib/main.dart` - Removed auto-permission request, goes to PermissionScreen
- ✅ `frontend/lib/screens/splash_screen.dart` - Navigates to PermissionScreen
- ✅ `frontend/lib/screens/permission_screen.dart` - New screen with GPS check
- ✅ `frontend/lib/services/permission_service.dart` - Permission handling service
- ✅ `frontend/lib/utils/location_service.dart` - Added GPS check methods
- ✅ `frontend/lib/screens/citizen/lodge_complaint_screen.dart` - GPS check before submission
- ✅ `frontend/lib/screens/citizen/citizen_map_screen.dart` - GPS check for map
- ✅ `frontend/lib/screens/authority/authority_map_screen.dart` - GPS check for map

## User Experience

### First Launch
1. Splash screen (2 seconds)
2. Permission screen appears
3. If GPS off → Blocking screen with instructions
4. User enables GPS → Returns to app
5. Permissions requested
6. User grants location → App continues
7. User can grant camera/mic or skip

### Subsequent Launches
- If GPS is off → Still blocks (GPS is always required)
- If permissions granted → Quick check, proceed
- If permissions denied → Request again

## Testing

### Test Scenario 1: GPS Off
1. Turn off GPS on device
2. Launch app
3. ✅ Should show "GPS Required" screen
4. ✅ App should not proceed
5. Tap "Enable GPS" → Opens settings
6. Enable GPS → Return to app
7. ✅ Should proceed to permission requests

### Test Scenario 2: GPS On, Permissions Denied
1. GPS on, but deny location permission
2. ✅ App should request permission
3. ✅ Should show permission status
4. ✅ Cannot proceed until location granted

### Test Scenario 3: All Permissions Granted
1. GPS on
2. Grant all permissions
3. ✅ Should show all green checkmarks
4. ✅ "Continue" button appears
5. ✅ Proceeds to Role Selection

## Important Notes

- **GPS is mandatory** - App will not start without it
- **Location permission is mandatory** - App blocks until granted
- **Camera/Microphone are optional** - App can continue without them
- Permission screen appears **every time** GPS is off (even on subsequent launches)
