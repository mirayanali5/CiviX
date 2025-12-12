# CiviX Testing Checklist

Use this checklist to systematically test all features of the CiviX app.

## Pre-Testing Setup

- [ ] Backend server is running (`npm start` in backend folder)
- [ ] Backend health check works: `curl http://localhost:3000/api/health`
- [ ] Database is connected and schema is applied
- [ ] Supabase storage bucket `civix-media` exists
- [ ] All environment variables are set in backend `.env`
- [ ] APK is built and installed on device
- [ ] Device and computer are on same network
- [ ] API endpoint in app matches computer's IP address

## 1. Initial App Launch

- [ ] App opens without crashing
- [ ] Splash screen displays "CiviX" logo
- [ ] Automatically navigates to Role Selection after 2 seconds
- [ ] Role Selection screen shows "Citizen" and "Authority" options

## 2. Citizen Flow - Authentication

### 2.1 Signup
- [ ] Can navigate to Citizen Login screen
- [ ] "Create Account" button works
- [ ] Signup form displays all fields:
  - [ ] Name field
  - [ ] Email field
  - [ ] Password field
  - [ ] Confirm Password field
  - [ ] Account Type selection (Private/Public)
- [ ] Form validation works:
  - [ ] Shows error if name is empty
  - [ ] Shows error if email is invalid
  - [ ] Shows error if password is too short
  - [ ] Shows error if passwords don't match
- [ ] Account Type defaults to "Private"
- [ ] Can select "Public" account type
- [ ] Signup succeeds with valid data
- [ ] Redirects to Dashboard after successful signup
- [ ] User data is saved correctly

### 2.2 Login
- [ ] Can enter email and password
- [ ] Password visibility toggle works
- [ ] "Forgot Password" button exists (feature may not be implemented)
- [ ] Login succeeds with correct credentials
- [ ] Login fails with wrong credentials (shows error message)
- [ ] Redirects to Dashboard after successful login

## 3. Citizen Flow - Dashboard

- [ ] Dashboard loads without errors
- [ ] Stats cards display:
  - [ ] Open Complaints count
  - [ ] Resolved Complaints count
  - [ ] Total Complaints count
- [ ] "New Complaint" button is visible and works
- [ ] Search bar is functional
- [ ] Complaint list loads and displays:
  - [ ] Complaint thumbnails
  - [ ] Status tags (Open/In-Progress/Resolved)
  - [ ] Reporter name (You/Anonymous/Public Name)
  - [ ] Description preview
  - [ ] Department label
  - [ ] Upvote count
  - [ ] GPS coordinates (clickable)
- [ ] Can tap complaint card to view details
- [ ] Can navigate to Map view
- [ ] Can navigate to Profile

## 4. Citizen Flow - Lodge Complaint

### 4.1 Photo Capture
- [ ] Camera permission is requested
- [ ] Can take photo using camera
- [ ] Photo preview displays correctly
- [ ] Can delete photo and retake
- [ ] Submit button is disabled without photo

### 4.2 GPS Location
- [ ] Location permission is requested
- [ ] Can get current location
- [ ] GPS coordinates display correctly
- [ ] Can refresh location
- [ ] Submit button is disabled without GPS

### 4.3 Description
- [ ] Can enter text description
- [ ] Text field accepts multiple lines
- [ ] Either description OR audio is required (not both)

### 4.4 Audio Recording
- [ ] Microphone permission is requested
- [ ] Can start recording audio
- [ ] Recording indicator shows while recording
- [ ] Can stop recording
- [ ] Audio file is saved
- [ ] Visual indicator shows audio is recorded

### 4.5 Tags
- [ ] Can enter comma-separated tags
- [ ] Tags field is optional

### 4.6 Submission
- [ ] Submit button is disabled until photo + GPS are present
- [ ] Submit button is disabled if neither description nor audio is provided
- [ ] Can submit complaint with all required fields
- [ ] Loading indicator shows during submission
- [ ] Success message displays after submission
- [ ] Redirects to Dashboard after success
- [ ] Complaint appears in dashboard list

### 4.7 Duplicate Detection
- [ ] Submitting duplicate complaint (same location + similar text) shows duplicate modal
- [ ] For logged-in users: Auto-upvotes existing complaint
- [ ] For guests: Shows existing complaint

## 5. Citizen Flow - Complaint Details

- [ ] Complaint details screen loads
- [ ] Full image displays correctly
- [ ] Title/Description displays
- [ ] Status tag shows correct status
- [ ] Department label displays
- [ ] Tags display (if any)
- [ ] GPS coordinates are clickable
- [ ] Clicking GPS opens Google Maps
- [ ] Upvote button works
- [ ] Upvote count updates after upvoting
- [ ] Timeline shows:
  - [ ] Created date
  - [ ] In-Progress date (if applicable)
  - [ ] Resolved date (if applicable)
- [ ] Audio transcript displays (if audio was recorded)
- [ ] Translated transcript displays (if non-English)

## 6. Citizen Flow - Map View

- [ ] Map loads with current location
- [ ] Complaint markers appear on map
- [ ] Can zoom and pan map
- [ ] Can tap marker to see info window
- [ ] Info window shows:
  - [ ] Complaint title
  - [ ] Upvote count
  - [ ] Status
- [ ] Can tap "Open Details" from info window
- [ ] Navigates to complaint details screen

## 7. Citizen Flow - Profile

- [ ] Profile screen loads
- [ ] User name displays correctly
- [ ] Email displays correctly
- [ ] Account type displays correctly
- [ ] Total complaints count displays
- [ ] "View My Complaints" button exists
- [ ] Permissions section shows:
  - [ ] Camera permission status
  - [ ] Microphone permission status
  - [ ] GPS permission status
- [ ] "Switch to Authority Login" button works
- [ ] Logout button works
- [ ] After logout, redirects to Role Selection

## 8. Authority Flow - Authentication

- [ ] Can navigate to Authority Login screen
- [ ] Login form displays email and password fields
- [ ] Can login with authority credentials
- [ ] Login fails with wrong credentials
- [ ] Redirects to Authority Dashboard after login

## 9. Authority Flow - Dashboard

- [ ] Authority Dashboard loads
- [ ] Stats cards display:
  - [ ] Open complaints count
  - [ ] In-Progress complaints count
  - [ ] Resolved complaints count
  - [ ] Total complaints count
- [ ] Only department-specific complaints are shown
- [ ] Complaint list displays:
  - [ ] Complaint thumbnails
  - [ ] Reporter name or Anonymous
  - [ ] Complaint ID
  - [ ] Status
  - [ ] Department
  - [ ] Upvote count
  - [ ] GPS coordinates (clickable)
- [ ] Can tap complaint to view resolution page
- [ ] Can navigate to Map view
- [ ] Can navigate to History
- [ ] Can navigate to Profile

## 10. Authority Flow - Complaint Resolution

- [ ] Resolution screen loads with complaint details
- [ ] Before image displays
- [ ] Complaint description displays
- [ ] GPS coordinates are clickable
- [ ] Can upload resolution photos (multiple)
- [ ] Can add resolution notes
- [ ] "Mark In-Progress" button works
- [ ] "Resolve" button works
- [ ] At least one resolution photo is required
- [ ] Status updates after resolution
- [ ] Redirects to dashboard after resolution

## 11. Authority Flow - Map View

- [ ] Map loads with department complaints only
- [ ] Markers appear for department complaints
- [ ] Can tap marker to view complaint
- [ ] Navigates to resolution screen

## 12. Authority Flow - History

- [ ] History screen loads
- [ ] Shows list of resolved complaints
- [ ] Each entry shows:
  - [ ] Before image
  - [ ] After image(s)
  - [ ] Resolution date
  - [ ] Notes (if any)

## 13. Authority Flow - Profile

- [ ] Profile screen loads
- [ ] Name displays correctly
- [ ] Email displays correctly
- [ ] Department displays correctly
- [ ] Account type shows "Public"
- [ ] Permissions status displays
- [ ] "Switch to Citizen Login" button works
- [ ] Logout button works

## 14. Cross-Feature Testing

### 14.1 Anonymous Complaints
- [ ] Can lodge complaint without login
- [ ] Complaint is created with guest_id
- [ ] Cannot upvote complaints as guest
- [ ] Can view complaints without login

### 14.2 Privacy Settings
- [ ] Private account: Name shows as "Anonymous" to others
- [ ] Public account: Name shows to others
- [ ] Account type cannot be changed after signup

### 14.3 Department Classification
- [ ] Keyword-based classification works
- [ ] Gemini AI fallback works when no keywords match
- [ ] Department is assigned correctly

### 14.4 Error Handling
- [ ] Network errors show appropriate messages
- [ ] Invalid data shows validation errors
- [ ] Backend errors are handled gracefully

## 15. Performance Testing

- [ ] App loads quickly (< 3 seconds)
- [ ] Images load efficiently
- [ ] List scrolling is smooth
- [ ] Map interactions are responsive
- [ ] No memory leaks during extended use

## 16. Network Testing

- [ ] Works on WiFi connection
- [ ] Works on mobile data connection
- [ ] Handles network disconnection gracefully
- [ ] Reconnects automatically when network returns

## 17. Device-Specific Testing

- [ ] Test on different Android versions (8+)
- [ ] Test on different screen sizes
- [ ] Test in portrait and landscape (if supported)
- [ ] Test with different network speeds

## Notes

- Mark each item as you test
- Note any bugs or issues found
- Test on actual device, not just emulator
- Test with real backend, not mock data
- Test with actual GPS location (not mock location)

## Bug Report Template

If you find bugs, note:
1. **Feature**: Which feature has the bug
2. **Steps to Reproduce**: How to trigger the bug
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Device Info**: Android version, device model
6. **Screenshots**: If applicable
