# CiviX - Civic Complaint System

A complete civic complaint system for Hyderabad GHMC with AI-powered classification, duplicate detection, and real-time workflows.

## Project Structure

```
CiviX Local/
├── backend/          # Node.js/Express API server
├── frontend/         # Flutter mobile application
└── NOTES/           # Documentation and database schemas
```

## Features

### Core Features
- ✅ **Mandatory Photo + GPS** - No complaint can be created without both
- ✅ **Audio Transcription** - Supports multiple languages with translation
- ✅ **AI Department Classification** - Keyword-based + Gemini AI fallback
- ✅ **Duplicate Detection** - 250m radius with text similarity
- ✅ **Anonymous Complaints** - Guests can report without login
- ✅ **Google Maps Integration** - Click coordinates to open maps
- ✅ **Real-time Workflows** - Status tracking and resolution

### Citizen Features
- Dashboard with stats
- Map view of all complaints
- Lodge complaints with photo/audio
- Upvote complaints
- View complaint details
- Profile management

### Authority Features
- Department-specific dashboard
- View department complaints
- Resolve complaints with photos
- Resolution history
- Status management

## Setup

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment:
```bash
cp .env.example .env
# Edit .env with your credentials
```

4. Set up database:
- Create PostgreSQL database or use Supabase
- Run SQL schema from `NOTES/Table structure.txt`

5. Run server:
```bash
npm start
# or for development
npm run dev
```

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure API endpoint in `lib/services/api_service.dart`

4. Add Google Maps API key for Android/iOS

5. Run app:
```bash
flutter run
```

## Environment Variables

### Backend (.env)
- `PORT` - Server port (default: 3000)
- `DATABASE_URL` - PostgreSQL connection string
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_KEY` - Supabase anon key
- `SUPABASE_SERVICE_KEY` - Supabase service key
- `JWT_SECRET` - JWT signing secret
- `GOOGLE_CLOUD_PROJECT_ID` - GCP project ID
- `GOOGLE_APPLICATION_CREDENTIALS` - Path to GCP service account key
- `GEMINI_API_KEY` - Google Gemini API key

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Citizen signup
- `POST /api/auth/login` - Citizen login
- `POST /api/auth/authority/login` - Authority login
- `GET /api/auth/me` - Get current user

### Complaints
- `POST /api/complaints` - Create complaint
- `GET /api/complaints` - Get all complaints
- `GET /api/complaints/:id` - Get single complaint
- `POST /api/complaints/:id/upvote` - Upvote complaint

### Authority
- `GET /api/authority/dashboard` - Authority dashboard
- `GET /api/authority/complaints` - Department complaints
- `POST /api/authority/complaints/:id/resolve` - Resolve complaint
- `GET /api/authority/history` - Resolution history

## Department Classification

The system uses keyword matching first, then falls back to Gemini AI:

- **GHMC Sanitation** - garbage, waste, cleaning, etc.
- **GHMC Road & Engineering** - road, pothole, construction, etc.
- **HMWSSB (Water Board)** - water, leak, drainage, etc.
- **TSSPDCL (Electricity)** - light, power, transformer, etc.
- **GHMC Town Planning** - illegal construction, encroachment, etc.
- **GHMC Public Health** - mosquito, pest, stray dog, etc.

## Duplicate Detection

- **Radius**: 250 meters
- **Text Similarity**: ≥ 0.3
- **Behavior**: Auto-upvote for logged-in users, return existing for guests

## License

This project is for civic engagement and public service.
