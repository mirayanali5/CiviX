import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/permission_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️  Failed to load .env file: $e');
    print('   Make sure .env file exists in frontend root directory');
  }
  
  // Initialize Supabase for Google OAuth
  try {
    final supabaseUrl = SupabaseConfig.url;
    final supabaseAnonKey = SupabaseConfig.anonKey;
    
    if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('✅ Supabase initialized successfully');
    } else {
      print('⚠️  Supabase URL or Anon Key is missing in .env file');
    }
  } catch (e) {
    print('⚠️  Supabase initialization error: $e');
    // Continue without Supabase if initialization fails
  }
  
  runApp(const CiviXApp());
}

class CiviXApp extends StatelessWidget {
  const CiviXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'CiviX',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
