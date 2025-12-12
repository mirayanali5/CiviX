# Department Field Note

Your Supabase `profiles` table doesn't have a `department` column, but the authority routes need it to filter complaints.

## Solutions:

### Option 1: Add department to profiles table
```sql
ALTER TABLE profiles ADD COLUMN department TEXT;
UPDATE profiles SET department = 'GHMC Sanitation' WHERE role = 'authority';
```

### Option 2: Store department in JWT token
When creating authority users, include department in JWT payload.

### Option 3: Create authority_departments table
```sql
CREATE TABLE authority_departments (
  user_id UUID REFERENCES profiles(id),
  department TEXT,
  PRIMARY KEY (user_id)
);
```

**Current code assumes department is available in `req.user.department` from JWT token.**
