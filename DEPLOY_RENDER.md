# Deploy CiviX Backend on Render

This guide walks you through deploying the CiviX backend on [Render](https://render.com) so you can use the app from anywhere without running the server locally.

---

## Prerequisites

1. **GitHub account** – Your CiviX project should be in a GitHub repo (Render deploys from Git).
2. **Render account** – Sign up at [render.com](https://render.com) (free tier is enough to start).
3. **Environment values** – You’ll need the same values you use locally (from `.env`), especially:
   - `DATABASE_URL` (e.g. Supabase Postgres connection string)
   - `JWT_SECRET` or `SUPABASE_JWT_SECRET`
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY` (or `SUPABASE_SERVICE_KEY`)

---

## Option A: Deploy with Blueprint (recommended)

The repo includes a `render.yaml` Blueprint that defines the backend service.

1. **Push your code to GitHub**  
   Make sure `render.yaml` (in the repo root) and the `backend/` folder are committed and pushed.

2. **Create a Blueprint on Render**
   - Go to [dashboard.render.com](https://dashboard.render.com).
   - Click **New +** → **Blueprint**.
   - Connect your GitHub account if needed, then select the **CiviX** repository.
   - Render will detect `render.yaml`. Click **Apply**.

3. **Enter environment variables**  
   Render will prompt for the secret env vars defined with `sync: false` in the Blueprint:
   - **DATABASE_URL** – Your Postgres URL (e.g. from Supabase).
   - **JWT_SECRET** – Same value you use locally (at least 32 characters).
   - **SUPABASE_URL** – Your Supabase project URL.
   - **SUPABASE_SERVICE_ROLE_KEY** – Your Supabase service role key.

4. **Wait for the first deploy**  
   Render will install dependencies and start the app. When it’s green, the service is live.

5. **Get your backend URL**  
   In the service page, copy the URL, e.g.:
   - `https://civix-backend.onrender.com`  
   The API base your app should use is: **`https://civix-backend.onrender.com/api`** (with `/api`).

---

## Option B: Deploy manually (without Blueprint)

1. **Push your code to GitHub**  
   Ensure the `backend/` folder is in the repo.

2. **Create a Web Service**
   - Go to [dashboard.render.com](https://dashboard.render.com) → **New +** → **Web Service**.
   - Connect GitHub and select the CiviX repo.
   - Use these settings:

   | Field           | Value           |
   |----------------|-----------------|
   | **Name**       | `civix-backend` |
   | **Region**     | Oregon (or your choice) |
   | **Branch**     | `main` (or your default) |
   | **Root Directory** | `backend` |
   | **Runtime**    | Node |
   | **Build Command**  | `npm install` |
   | **Start Command**  | `npm start` |
   | **Instance Type**  | Free (or Starter if you prefer) |

3. **Health check (optional but recommended)**  
   Under **Health Check Path**, set: **`/api/health`**.

4. **Environment variables**  
   In the **Environment** tab, add:

   **Required:**

   | Key                      | Value / note |
   |--------------------------|--------------|
   | `DATABASE_URL`           | Your Postgres connection string (e.g. from Supabase) |
   | `JWT_SECRET`             | Same as local; min 32 characters (or use `SUPABASE_JWT_SECRET`) |
   | `SUPABASE_URL`           | Your Supabase project URL |
   | `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (or `SUPABASE_SERVICE_KEY`) |

   **Optional (same as local):**

   | Key                | Purpose |
   |--------------------|--------|
   | `GEMINI_API_KEY` or `GEMINI_KEY` | AI department classification |
   | `NODE_ENV`         | Set to `production` (Render may set this automatically) |
   | `ALLOWED_ORIGINS`  | CORS; use `*` for development or list your app origins |

5. **Create Web Service**  
   Click **Create Web Service**. Wait for the first deploy to finish.

6. **Backend URL**  
   Your API base URL will be: **`https://<your-service-name>.onrender.com/api`**.

---

## After deployment

### 1. Test the API

- In the browser or with curl:
  - **Health:** `https://<your-service-name>.onrender.com/api/health`  
  You should see something like: `{"status":"ok","message":"CiviX API Server is running"}`.

### 2. Point the Flutter app to Render

- Open **`frontend/lib/config/api_config.dart`**.
- Set `baseUrl` to your Render API base (including `/api`), for example:
  - `static const String baseUrl = 'https://civix-backend.onrender.com/api';`
- Rebuild and run the app (e.g. `flutter run`). The app will now use the backend on Render from any network.

### 3. Free tier behavior

- On the free tier, the service may **spin down after ~15 minutes** of no traffic.
- The first request after spin-down can take **30–60 seconds** (cold start). Later requests are fast until it spins down again.
- For always-on behavior, use a paid plan (e.g. Starter).

---

## Troubleshooting

| Issue | What to check |
|-------|----------------|
| Build fails | Ensure **Root Directory** is `backend` and that `backend/package.json` and `backend/server.js` exist in the repo. |
| "Missing required environment variables" | Add all required env vars in Render → your service → **Environment**. |
| App can’t reach API | Confirm `frontend/lib/config/api_config.dart` `baseUrl` is exactly `https://...onrender.com/api` (with `/api`). |
| CORS errors (e.g. from a web app) | Add `ALLOWED_ORIGINS` in Render (e.g. `*` or your frontend origin). |
| 503 or long first load | Normal on free tier after idle; wait for the instance to wake up. |
| **Database ENETUNREACH** (Supabase IPv6) | Use Supabase’s **Connection pooler** URL instead of the direct DB URL. See **Fix DB connection (ENETUNREACH)** below. |

---

## Fix DB connection (ENETUNREACH / IPv6)

Supabase says: *"Direct connections to the database only work if your client is able to resolve IPv6 addresses. If you are connecting via the **Shared connection pooler**, you do not need [the IPv4 add-on] as our pooler resolves to IPv4 addresses."*

Render cannot reach Supabase’s **direct** host (`db.xxx.supabase.co`) over IPv6, so use the **Shared connection pooler** URL instead:

1. Open **[Supabase Dashboard](https://supabase.com/dashboard)** → your project.
2. Go to **Project Settings** (gear) → **Database**.
3. Scroll to **Connection string**.
4. Switch from **URI** (direct) to **Connection pooling** → **Session mode** (port 5432).
5. Copy the **URI** shown there. It will look like:  
   `postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres`  
   (same password as your direct connection; the host is `...pooler.supabase.com`, not `db....supabase.co`).
6. In **Render** → your service → **Environment**:
   - Set **DATABASE_URL** to this **pooler URI** (paste the one you copied).
7. **Save** and let Render **redeploy** (or trigger a manual deploy).

After deploy, logs will show **"DB: Using Supabase pooler; connection will be established on first request."** (the startup DB test is skipped for the pooler so you don’t see a timeout warning). **Try using the app** (e.g. login)—the first request may take up to ~60 seconds; later requests should be fast.

**Pooler URI format:** Username must be **`postgres.[PROJECT-REF]`** (e.g. `postgres.nwzpytaofgjhshefvkvo`), not just `postgres`. Get the exact URI from Supabase → Database → Connection pooling → Session mode.

---

## If login shows "Connection timeout"

If the app shows **"Connection timeout. Check network and try again"** on login, the backend (Render) is too far from your Supabase pooler (e.g. Oregon ↔ ap-south-1 Mumbai). **Deploy the backend in Singapore** so it’s closer to Supabase ap-south-1:

1. **Create a new Web Service** on Render (you can’t change region on an existing service):
   - [dashboard.render.com](https://dashboard.render.com) → **New +** → **Web Service**.
   - Connect the **same repo** (civix-backend).
   - **Name:** e.g. `civix-backend-sg`.
   - **Region:** choose **Singapore** (not Oregon).
   - **Root Directory:** `backend` (or leave blank if the repo root is the backend).
   - **Build:** `npm install` | **Start:** `npm start`.
   - Add the **same environment variables** (DATABASE_URL, JWT_SECRET, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, etc.).
2. **Deploy** and copy the new URL (e.g. `https://civix-backend-sg.onrender.com`).
3. **Update the app:** in `frontend/lib/config/api_config.dart` set  
   `baseUrl = 'https://YOUR-NEW-SERVICE.onrender.com/api'`.
4. **Rebuild and reinstall** the Flutter app, then try login again.

The app’s request timeout is 90 seconds so the first request has time to complete. New Blueprint deploys use `region: singapore` in `render.yaml` by default.

---

## Summary

1. Push code (with `render.yaml` and `backend/`) to GitHub.
2. Deploy on Render via **Blueprint** (Option A) or **Web Service** (Option B).
3. Set required env vars (and optional ones if you use them).
4. Set **`frontend/lib/config/api_config.dart`** `baseUrl` to `https://<your-service>.onrender.com/api`.
5. Rebuild the Flutter app and use it from anywhere.

Your CiviX backend is then available at the Render URL without running it locally.
