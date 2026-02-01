# Login setup – CiviX

## How login works

- **Citizens**: Sign up in the app (Create Account), then log in with that email and password.  
  Passwords are stored in `profiles.password` (plain text) and checked on `/api/auth/login`.

- **Authorities**: Do **not** sign up in the app. They must be created in the database (e.g. with the script below), then log in with that email and password.  
  Authority login uses `/api/auth/authority/login` and requires `profiles.role = 'authority'` and `profiles.department` set.

## 1. Citizen – first account

1. Open the app → choose **Citizen**.
2. Tap **Create Account**.
3. Enter name, email, password, account type → Sign up.
4. After signup you are logged in. To test login again: log out, then use the same email and password on the Citizen login screen.

## 2. Authority – first account

Authorities must exist in the `profiles` table with:

- `role = 'authority'`
- `department` set (e.g. `"Road"`, `"Sanitation"`, `"GHMC Sanitation"`)
- `password` set (plain text; login compares against this)

**Option A – Use the script (recommended)**

From the project root:

```bash
cd backend
node scripts/createAuthorityUser.js <email> <password> <department> [full_name]
```

Example:

```bash
node scripts/createAuthorityUser.js authority@test.com secret123 "Road" "Road Authority"
```

Then in the app: choose **Authority** → log in with that email and password.

**Option B – Insert in SQL**

```sql
INSERT INTO profiles (id, email, full_name, role, account_type, department, password)
VALUES (
  gen_random_uuid(),
  'authority@test.com',   -- email
  'Road Authority',        -- full_name
  'authority',            -- role (must be exactly 'authority')
  'public',               -- account_type
  'Road',                 -- department (must match complaint departments)
  'secret123'             -- password (plain text)
);
```

Then log in in the app with that email and password.

## 3. If login still fails

- **“Invalid email or password”**  
  - Citizen: make sure you signed up first with that email.  
  - Authority: make sure the profile exists with `role = 'authority'`, correct `department`, and the same password you type.

- **“Cannot reach server” / “Connection timeout”**  
  - Backend must be running: `cd backend && npm start`.  
  - In the app’s `api_service.dart`, `baseUrl` must use your machine’s IP (e.g. `http://192.168.1.100:8080/api`), not `localhost`.  
  - Phone and computer on the same Wi‑Fi.

- **“Account not configured” (authority)**  
  - That profile has no `password` or it is null.  
  - Recreate the authority with the script (or SQL) and set `password` to the value you will use to log in.

After any change to backend auth, restart the backend (`npm start`) and try again.
