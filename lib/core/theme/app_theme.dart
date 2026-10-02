import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static const List<AppColorScheme> palettes = [
    AppColorScheme(
      name: 'سبز مقاومت',
      primary: Color(0xFF1B5E20),
      secondary: Color(0xFFFFD700),
      accent: Color(0xFFFF6F00),
      surface: Color(0xFFF1F8E9),
      darkBg: Color(0xFF0A1A0B),
    ),
    AppColorScheme(
      name: 'نیلی شب',
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFF64B5F6),
      accent: Color(0xFF00E5FF),
      surface: Color(0xFFE3F2FD),
      darkBg: Color(0xFF061423),
    ),
    AppColorScheme(
      name: 'بنفش سلطنتی',
      primary: Color(0xFF4A148C),
      secondary: Color(0xFFBA68C8),
      accent: Color(0xFFE040FB),
      surface: Color(0xFFF3E5F5),
      darkBg: Color(0xFF1A0B2E),
    ),
    AppColorScheme(
      name: 'قرمز عاشورا',
      primary: Color(0xFFB71C1C),
      secondary: Color(0xFFFF8A65),
      accent: Color(0xFFFFB300),
      surface: Color(0xFFFFEBEE),
      darkBg: Color(0xFF2A0A0A),
    ),
    AppColorScheme(
      name: 'فیروزه شرقی',
      primary: Color(0xFF00695C),
      secondary: Color(0xFF4DB6AC),
      accent: Color(0xFF1DE9B6),
      surface: Color(0xFFE0F2F1),
      darkBg: Color(0xFF04211E),
    ),
    AppColorScheme(
      name: 'طلایی کویر',
      primary: Color(0xFF8D6E63),
      secondary: Color(0xFFFFCA28),
      accent: Color(0xFFFF7043),
      surface: Color(0xFFFBE9E7),
      darkBg: Color(0xFF1C1410),
    ),
  ];

  static ThemeData buildTheme({
    required int paletteIndex,
    required Brightness brightness,
  }) {
    final p = palettes[paletteIndex];
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? p.secondary : p.primary,
      secondary: isDark ? p.accent : p.secondary,
      tertiary: p.accent,
      surface: isDark ? const Color(0xFF1A1A1A) : p.surface,
      background: isDark ? p.darkBg : p.surface,
      onPrimary: isDark ? Colors.black : Colors.white,
      onSurface: isDark ? Colors.white : const Color(0xFF1A1A1A),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      fontFamily: GoogleFonts.vazirmatn().fontFamily,
      textTheme: GoogleFonts.vazirmatnTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.vazirmatn(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: scheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
          textStyle: GoogleFonts.vazirmatn(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.primary.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        selectedColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        side: BorderSide(color: scheme.primary.withOpacity(0.2)),
        labelStyle: GoogleFonts.vazirmatn(fontWeight: FontWeight.w600),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.primary,
        contentTextStyle: GoogleFonts.vazirmatn(color: scheme.onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class AppColorScheme {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color darkBg;

  const AppColorScheme({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.darkBg,
  });
}