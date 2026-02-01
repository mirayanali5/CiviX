import 'package:flutter/material.dart';

/// CiviX / CivicAssist-inspired theme: dark background, teal primary, orange for status.
/// Use for modern appearance and clarity with separate screens for major functionality.
class AppTheme {
  static const Color primaryTeal = Color(0xFF00D9C5);
  static const Color primaryTealDark = Color(0xFF00B8A3);
  static const Color statusOrange = Color(0xFFFF9F43);
  static const Color statusGreen = Color(0xFF00D26A);
  static const Color statusBlue = Color(0xFF6C9BCF);
  static const Color surfaceDark = Color(0xFF1A1E29);
  static const Color surfaceCard = Color(0xFF252B38);
  static const Color surfaceCardElevated = Color(0xFF2D3544);
  static const Color textPrimary = Color(0xFFF0F2F5);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFF374151);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        onPrimary: Colors.black87,
        secondary: statusOrange,
        onSecondary: Colors.black87,
        surface: surfaceDark,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        error: Color(0xFFEF4444),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: primaryTeal),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceCardElevated,
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      listTileTheme: const ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
      ),
    );
  }

  /// Light theme: white/grey surfaces, teal primary, same status colors.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryTealDark,
      scaffoldBackgroundColor: Colors.grey.shade50,
      colorScheme: ColorScheme.light(
        primary: primaryTealDark,
        onPrimary: Colors.white,
        secondary: statusOrange,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        onSurfaceVariant: Colors.grey.shade700,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTealDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTealDark,
          side: const BorderSide(color: primaryTealDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTealDark, width: 1.5),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade600),
        labelStyle: TextStyle(color: Colors.grey.shade700),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(color: Colors.black87, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade300, thickness: 1),
      listTileTheme: ListTileThemeData(
        textColor: Colors.black87,
        iconColor: Colors.grey.shade700,
      ),
    );
  }
}
