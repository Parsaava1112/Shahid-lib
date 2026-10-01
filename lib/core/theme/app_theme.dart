import 'package:flutter/material.dart';

class AppTheme {
  // پالت رنگی اصلی - سبز و طلایی (مرتبط با فرهنگ مقاومت)
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color accentGold = Color(0xFFFFA000);
  static const Color darkBackground = Color(0xFF0D1B0E);
  static const Color darkSurface = Color(0xFF1A2E1B);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFEEEEEE);

  // تم روشن
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentGold,
      surface: lightSurface,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: textDark,
      onSurface: textDark,
      onBackground: textDark,
    ),
    scaffoldBackgroundColor: lightBackground,
    fontFamily: 'Vazirmatn',
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: lightSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  // تم تاریک
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: accentGold,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: textDark,
      onSecondary: textDark,
      onSurface: textLight,
      onBackground: textLight,
    ),
    scaffoldBackgroundColor: darkBackground,
    fontFamily: 'Vazirmatn',
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: primaryGold,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: textDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}