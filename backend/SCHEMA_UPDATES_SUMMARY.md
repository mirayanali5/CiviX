# Schema Updates Summary

All backend code has been updated to match your Supabase schema.

## Changes Made

### 1. Table Names
- ✅ `users` → `profiles`
- ✅ All queries updated

### 2. Column Names
- ✅ `gps_lat` → `latitude`
- ✅ `gps_long` → `longitude`
- ✅ `photo_url` → `image_url`
- ✅ `transcript_translated` → `translated_text`
- ✅ `name` → `full_name` (in profiles)
- ✅ All queries updated

### 3. Status Values
- ✅ `'Open'` → `'open'`
- ✅ `'Resolved'` → `'resolved'`
- ✅ Removed `'In-Progress'` (your schema only has 'open' and 'resolved')

### 4. User ID Handling
- ✅ `user_id` is UUID (can be null)
- ✅ `guest_id` is text (for anonymous complaints)
- ✅ Updated complaint creation to handle both

### 5. Resolutions Table
- ✅ `authority_user_id` → `authority_id`
- ✅ `photo_url` → `images` (array)
- ✅ Updated to store array of image URLs

### 6. Bucket Names
- ✅ `complaint-images` (for photos)
- ✅ `complaint-audio` (for audio)
- ✅ `resolution-images` (for resolution photos)

## Files Updated

- ✅ `backend/routes/complaints.js`
- ✅ `backend/routes/authority.js`
- ✅ `backend/routes/users.js`
- ✅ `backend/routes/auth.js` (partial - see AUTH_NOTE.md)
- ✅ `backend/utils/duplicateDetection.js`

## Authentication Note

Your schema uses Supabase Auth (`auth.users`), but the backend code currently uses custom JWT auth. See `AUTH_NOTE.md` for details.

**Options:**
1. Use Supabase Auth (recommended) - verify Supabase tokens in backend
2. Keep custom auth - add `password_hash` column or separate auth table

## Testing

After updating, test:
1. Create complaint (with user_id UUID or guest_id text)
2. Query complaints (should use correct column names)
3. Update status (should use 'open'/'resolved')
4. Create resolution (should use images array)

## Remaining Issues

1. **Auth**: Decide on Supabase Auth vs Custom Auth
2. **Department**: Your schema doesn't have `department` in profiles - may need to add or query differently
3. **Status values**: Frontend may need updates to use lowercase status
