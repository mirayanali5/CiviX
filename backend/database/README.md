# Database Setup

## PostgreSQL/Supabase Setup

1. Create a new database (or use Supabase)

2. Run the schema:
```bash
psql -U your_user -d your_database -f schema.sql
```

Or in Supabase SQL Editor, paste and run the contents of `schema.sql`

## Initial Data

### Create Authority Users

You can create authority users manually via SQL:

```sql
-- Example: Create a Sanitation Authority user
INSERT INTO users (id, name, email, password_hash, role, department, account_type)
VALUES (
  'auth_sanitation_001',
  'Sanitation Officer',
  'sanitation@ghmc.gov.in',
  '$2b$10$...', -- Use bcrypt to hash password
  'authority',
  'GHMC Sanitation',
  'public'
);
```

Or use the backend API after hashing passwords with bcrypt.

## Environment Variables

Set these in your `.env` file:

- `DATABASE_URL` - Full PostgreSQL connection string
- `SUPABASE_URL` - Supabase project URL (if using Supabase)
- `SUPABASE_KEY` - Supabase anon key
- `SUPABASE_SERVICE_KEY` - Supabase service key (for admin operations)
