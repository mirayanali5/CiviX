# CiviX Backend API

Backend server for the CiviX civic complaint system.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp env.example .env
# Edit .env with your credentials
# See ENV_SETUP.md for detailed instructions
```

3. Validate environment variables:
```bash
npm run validate-env
```

3. Set up database:
- Create PostgreSQL database or use Supabase
- Run the SQL schema from `NOTES/Table structure.txt`

4. Run the server:
```bash
npm start
# or for development
npm run dev
```

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Citizen signup
- `POST /api/auth/login` - Citizen login
- `POST /api/auth/authority/login` - Authority login
- `GET /api/auth/me` - Get current user

### Complaints
- `POST /api/complaints` - Create complaint (requires photo + GPS)
- `GET /api/complaints` - Get all complaints
- `GET /api/complaints/:id` - Get single complaint
- `POST /api/complaints/:id/upvote` - Upvote complaint

### Users
- `GET /api/users/dashboard` - Get dashboard stats
- `GET /api/users/my-complaints` - Get user's complaints
- `GET /api/users/profile` - Get user profile

### Authority
- `GET /api/authority/dashboard` - Authority dashboard stats
- `GET /api/authority/complaints` - Get department complaints
- `GET /api/authority/complaints/:id` - Get complaint for resolution
- `PATCH /api/authority/complaints/:id/status` - Update complaint status
- `POST /api/authority/complaints/:id/resolve` - Resolve complaint
- `GET /api/authority/history` - Get resolution history

## Features

- ✅ Photo + GPS validation
- ✅ Audio transcription & translation
- ✅ AI-powered department classification
- ✅ Duplicate detection (250m radius)
- ✅ Supabase storage integration
- ✅ JWT authentication
- ✅ Anonymous complaint support
