# Your CiviX login credentials (from profiles table)

Use these **exactly** in the app (no extra spaces).

---

## Citizen login (choose “Citizen” then “Login”)

| Email | Password |
|-------|----------|
| **mots4@gmail.com** | **motassim** |
| **shoaib@gmail.com** | **123456** |

---

## Authority login (choose “Authority” then “Login”)

| Email | Password |
|-------|----------|
| **mirayanaliunofficial@gmail.com** | **ayan39258957** |

**Important:** This authority user has **no department** in the database. After login, the authority dashboard will show “Department not assigned” until you set one.

**Fix:** Run this in your database (Supabase SQL editor or psql):

```sql
UPDATE profiles
SET department = 'General'
WHERE email = 'mirayanaliunofficial@gmail.com' AND role = 'authority';
```

You can use any department name that matches your complaints (e.g. `'Road'`, `'Sanitation'`, `'General'`). Then log in again as authority; the dashboard should work.

---

## If login still fails

1. **Restart backend:** `cd backend` then `npm start`
2. **Type carefully:** Copy-paste email and password from above (no spaces before/after)
3. **Citizen vs Authority:** Use the correct screen (Citizen login for mots4/shoaib, Authority login for mirayanaliunofficial)
4. **Network:** Phone and PC on same Wi‑Fi; app `baseUrl` = `http://192.168.0.101:8080/api`
