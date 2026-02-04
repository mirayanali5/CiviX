import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API server URL for the CiviX backend.
/// Values are loaded from .env file in the frontend root directory.
///
/// Production (deployed on Render):
/// - Set API_BASE_URL in .env to your Render backend URL + /api, e.g. https://civix-backend.onrender.com/api
/// - See DEPLOY_RENDER.md for deployment steps.
///
/// Local development (same Wi‑Fi):
/// - Set API_BASE_URL in .env to your PC's local IP, e.g. http://192.168.0.101:8080/api
/// - Backend: `cd backend && npm run dev` — it prints "Mobile: http://X.X.X.X:8080/api"
class ApiConfig {
  /// Base URL including /api (from .env).
  /// Falls back to production URL if not set in .env
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://civix-backend-df45.onrender.com/api';
}
