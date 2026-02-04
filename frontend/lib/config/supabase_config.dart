import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration for authentication.
/// Values are loaded from .env file in the frontend root directory.
class SupabaseConfig {
  /// Supabase project URL (from .env)
  static String get url => dotenv.env['SUPABASE_URL'] ?? 'https://nwzpytaofgjhshefvkvo.supabase.co';
  
  /// Supabase anon/public key (from .env)
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  /// Deep link redirect URL for OAuth callbacks (from .env)
  static String get redirectUrl => dotenv.env['OAUTH_REDIRECT_URL'] ?? 'civix://login-callback';
}
