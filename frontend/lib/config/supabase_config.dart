import 'package:flutter_dotenv/flutter_dotenv.dart';


class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? 'https://nwzpytaofgjhshefvkvo.supabase.co';
  
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static String get redirectUrl => dotenv.env['OAUTH_REDIRECT_URL'] ?? 'civix://login-callback';
}
