-- CiviX Database Schema

-- Users table (updated with password_hash)
CREATE TABLE IF NOT EXISTS public.users (
    -- Matches the Firebase Auth UID or generated user ID
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT, -- For JWT-based auth (nullable for Firebase Auth users)
    role TEXT NOT NULL DEFAULT 'citizen'::text, -- 'citizen' or 'authority'
    department TEXT NULL, -- Required for Authority role
    account_type TEXT NOT NULL DEFAULT 'private'::text, -- 'private' or 'public'
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    -- Ensure roles are explicitly defined
    CONSTRAINT check_role_type CHECK (role IN ('citizen'::text, 'authority'::text)),
    CONSTRAINT check_account_type CHECK (account_type IN ('private'::text, 'public'::text))
);

-- Complaints table
CREATE TABLE IF NOT EXISTS public.complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL, -- Links to Firebase Auth UID/public.users.id
    transcript TEXT NOT NULL,
    transcript_translated TEXT NULL DEFAULT ''::text,
    department TEXT NULL DEFAULT ''::text, -- AI-predicted
    tags TEXT[] NULL,
    gps_lat DOUBLE PRECISION NOT NULL,
    gps_long DOUBLE PRECISION NOT NULL,
    photo_url TEXT NOT NULL, -- Mandatory image proof
    audio_url TEXT NULL DEFAULT ''::text,
    status TEXT NOT NULL DEFAULT 'Open'::text, -- 'Open', 'In-Progress', 'Resolved'
    report_count BIGINT NOT NULL DEFAULT 1, -- Upvote count
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    -- Foreign Key Constraint
    CONSTRAINT fk_complaint_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL
);

-- Upvotes table
CREATE TABLE IF NOT EXISTS public.upvotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL,
    user_id TEXT NOT NULL, -- UID of the user who upvoted

    -- Ensures a user can only upvote a single complaint once
    CONSTRAINT unique_upvote UNIQUE (complaint_id, user_id),
    
    -- Foreign Key to the complaints table
    CONSTRAINT fk_upvote_complaint FOREIGN KEY (complaint_id) 
        REFERENCES public.complaints (id) ON DELETE CASCADE,
        
    -- Foreign Key to the users table
    CONSTRAINT fk_upvote_user FOREIGN KEY (user_id) 
        REFERENCES public.users(id) ON DELETE CASCADE
);

-- Resolutions table
CREATE TABLE IF NOT EXISTS public.resolutions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL,
    authority_user_id TEXT NOT NULL, -- UID of the Authority member who resolved it
    photo_url TEXT NOT NULL, -- Resolution proof image
    notes TEXT DEFAULT ''::text,
    resolved_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),

    -- Foreign Key to the complaints table
    CONSTRAINT fk_resolutions_complaint FOREIGN KEY (complaint_id) 
        REFERENCES public.complaints (id) ON DELETE CASCADE,
        
    -- Foreign Key to the users table (Authority member)
    CONSTRAINT fk_resolution_authority FOREIGN KEY (authority_user_id) 
        REFERENCES public.users(id) ON DELETE CASCADE
);

-- Index for efficient querying of Open/Trending complaints by location/status
CREATE INDEX IF NOT EXISTS idx_complaints_trending ON public.complaints 
USING btree (status, report_count DESC)
WHERE (status = 'Open'::text OR status = 'In-Progress'::text);

-- Index for location-based queries (duplicate detection)
CREATE INDEX IF NOT EXISTS idx_complaints_location ON public.complaints 
USING btree (gps_lat, gps_long);

-- Index for department queries
CREATE INDEX IF NOT EXISTS idx_complaints_department ON public.complaints 
USING btree (department, status);
