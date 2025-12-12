# Audio Processing Fix

## Issue
400 error when submitting audio files (M4A format)

## Root Cause
M4A files were being processed with incorrect encoding type. Google Speech API requires `M4A_AAC` encoding for M4A files, not `MP3` or `ENCODING_UNSPECIFIED`.

## Fix Applied

1. **Updated encoding detection:**
   - Changed from `MP3` to `M4A_AAC` for M4A files
   - M4A_AAC encoding doesn't require `sampleRateHertz` (auto-detected)

2. **Improved error logging:**
   - Added detailed error logging with code and stack trace
   - Better debugging information

3. **Fixed config:**
   - Only add `sampleRateHertz` when required by encoding type
   - M4A_AAC can auto-detect sample rate

## Files Modified
- `backend/utils/audioProcessing.js` - Fixed encoding type for M4A
- `backend/routes/complaints.js` - Improved error logging

## Testing
After restarting backend, audio submission should work correctly with M4A files.
