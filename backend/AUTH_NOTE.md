# Authentication Note

Your Supabase schema uses `profiles` table linked to `auth.users` (Supabase Auth).

However, the current backend code uses JWT with custom password hashing stored in a `users` table.

## Two Options:

### Option 1: Use Supabase Auth (Recommended if using Supabase)
- Frontend authenticates with Supabase Auth
- Backend verifies Supabase JWT tokens
- Profiles are auto-created via trigger

### Option 2: Custom JWT Auth (Current Implementation)
- Backend handles signup/login with password hashing
- Stores passwords in a separate `users` table
- Profiles table is separate

**Current code uses Option 2.** If you want Option 1, you'll need to:
1. Remove password hashing from backend
2. Use Supabase Auth SDK to verify tokens
3. Update auth middleware

For now, I've updated the code to work with `profiles` table structure, but you may need to add a `password_hash` column or use Supabase Auth.
