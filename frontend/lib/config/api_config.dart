/// API server URL for the CiviX backend.
///
/// Production (deployed on Render):
/// - Set to your Render backend URL + /api, e.g. https://civix-backend.onrender.com/api
/// - See DEPLOY_RENDER.md for deployment steps.
///
/// Local development (same Wi‑Fi):
/// - Use your PC's local IP, e.g. http://192.168.0.101:8080/api
/// - Backend: `cd backend && npm run dev` — it prints "Mobile: http://X.X.X.X:8080/api"
class ApiConfig {
  /// Base URL including /api.
  /// For production: https://YOUR-SERVICE.onrender.com/api
  /// For local: http://YOUR_PC_IP:8080/api
  static const String baseUrl = 'https://civix-backend-df45.onrender.com/api';
}
