# Database Schema Migration Notes

Your Supabase schema uses different column names than the original code. Here are the mappings:

## Column Name Mappings

| Original Code | Your Supabase Schema |
|--------------|---------------------|
| `users` table | `profiles` table |
| `gps_lat` | `latitude` |
| `gps_long` | `longitude` |
| `photo_url` | `image_url` |
| `audio_url` | `audio_url` (same) |
| `transcript_translated` | `translated_text` |
| `status = 'Open'` | `status = 'open'` |
| `status = 'Resolved'` | `status = 'resolved'` |
| `status = 'In-Progress'` | Not in your schema (use 'open') |
| `user_id` (text) | `user_id` (UUID) or `guest_id` (text) |
| `report_count` | `report_count` (same) |

## Table Structure

Your schema:
- `profiles` - User profiles (linked to auth.users)
- `complaints` - Complaints with user_id (UUID) or guest_id (text)
- `resolutions` - Resolution records
- `upvotes` - Separate upvotes table
- `departments` - Department lookup

## Status Values

Your schema uses lowercase: `'open'`, `'resolved'`
Original code used: `'Open'`, `'Resolved'`, `'In-Progress'`

## User ID Handling

- Logged-in users: `user_id` (UUID from profiles.id)
- Guest users: `guest_id` (text string)
- One of these must be set, not both
