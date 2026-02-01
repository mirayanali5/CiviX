# Authority department fix (HMWSSB)

## What was fixed

1. **Department names aligned with your `departments` table**  
   New complaints are now stored with short names: `HMWSSB`, `TSSPDCL`, `GHMC Road and Engineering`, etc., so they match authority profiles and your table.

2. **Flexible department matching**  
   Authority with department **HMWSSB** now sees:
   - Complaints with department **HMWSSB**
   - Complaints with department **HMWSSB (Water Board)** (old data)

   The same logic applies for other departments (e.g. TSSPDCL vs TSSPDCL (Electricity)).

## Set your authority user’s department to HMWSSB

If the authority account does not have `department = 'HMWSSB'`, run this in your database (Supabase SQL or psql):

```sql
UPDATE profiles
SET department = 'HMWSSB'
WHERE role = 'authority' AND email = 'mirayanaliunofficial@gmail.com';
```

(Change the email if you use a different authority account.)

## Restart backend

```bash
cd backend
npm start
```

Then log in as authority again; open complaints for HMWSSB should appear on the dashboard, map, and resolution flow.

## "No complaints found" for HMWSSB

That usually means there are **no complaints in the database** with department HMWSSB (or HMWSSB (Water Board)).

**1. Check what’s in the database**

Restart the backend and log in as authority again. In the backend console you’ll see a line like:

```text
Complaints in DB by department: [ { department: 'GHMC Sanitation', cnt: '3' }, ... ]
```

That shows which departments have complaints. If HMWSSB is missing or has 0, you need HMWSSB complaints.

**2. Create an HMWSSB complaint (as citizen)**

1. Log in as **citizen** (or use a guest flow if you have one).
2. Lodge a **new complaint** with a **water-related** description, for example:
   - "Water leak on our street"
   - "Sewer overflow near the park"
   - "Pipe burst, dirty water"
3. Submit with photo and GPS.
4. The system will classify it as **HMWSSB**.
5. Log in as **authority** again; that complaint should appear under HMWSSB.

**3. (Optional) Point existing complaints at HMWSSB**

If you already have complaints that should be HMWSSB but have a different or null department, run in SQL (adjust IDs if needed):

```sql
-- See existing complaints and their departments
SELECT id, department, description, created_at FROM complaints ORDER BY created_at DESC LIMIT 20;

-- Set one complaint to HMWSSB (replace <complaint-id> with real UUID)
-- UPDATE complaints SET department = 'HMWSSB' WHERE id = '<complaint-id>';
```

---

## Valid department values (from your `departments` table)

- GHMC Sanitation  
- GHMC Road and Engineering  
- HMWSSB  
- TSSPDCL  
- GHMC Town Planning  
- GHMC Public Health / Entomology  

Use exactly these (e.g. `HMWSSB`) in `profiles.department` for authority users.
