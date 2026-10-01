import 'package:flutter/material.dart';

/// پالت‌های رنگی قابل انتخاب برای اپلیکیشن
class AppThemeColors {
  static const List<Map<String, dynamic>> colorSchemes = [
    {
      'name': 'سبز مقاومت',
      'primary': Color(0xFF1B5E20),
      'secondary': Color(0xFFFFD700),
      'accent': Color(0xFFFFA000),
      'darkBg': Color(0xFF0D1B0E),
      'darkSurface': Color(0xFF1A2E1B),
    },
    {
      'name': 'آبی آسمانی',
      'primary': Color(0xFF0D47A1),
      'secondary': Color(0xFF42A5F5),
      'accent': Color(0xFF00BCD4),
      'darkBg': Color(0xFF0A1929),
      'darkSurface': Color(0xFF132F4C),
    },
    {
      'name': 'بنفش شب',
      'primary': Color(0xFF4A148C),
      'secondary': Color(0xFFAB47BC),
      'accent': Color(0xFF7C4DFF),
      'darkBg': Color(0xFF1A0B2E),
      'darkSurface': Color(0xFF2D1B4E),
    },
    {
      'name': 'قرمز عاشورایی',
      'primary': Color(0xFFB71C1C),
      'secondary': Color(0xFFFF7043),
      'accent': Color(0xFFFFAB40),
      'darkBg': Color(0xFF2A0A0A),
      'darkSurface': Color(0xFF3E1414),
    },
    {
      'name': 'فیروزه‌ای',
      'primary': Color(0xFF00695C),
      'secondary': Color(0xFF26A69A),
      'accent': Color(0xFF4DB6AC),
      'darkBg': Color(0xFF04211E),
      'darkSurface': Color(0xFF0E3A36),
    },
  ];
}

/// تم اصلی اپلیکیشن - با پشتیبانی از رنگ پویا و حالت تاریک/روشن
class AppTheme {
  // رنگ‌های پایه پیش‌فرض
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color accentGold = Color(0xFFFFA000);
  static const Color darkBackground = Color(0xFF0D1B0E);
  static const Color darkSurface = Color(0xFF1A2E1B);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFEEEEEE);

  /// ساخت تم پویا بر اساس رنگ انتخاب‌شده و روشنایی
  static ThemeData getTheme({
    required int colorIndex,
    required Brightness brightness,
  }) {
    final scheme = AppThemeColors.colorSchemes[colorIndex];
    final isDark = brightness == Brightness.dark;
    final primary = scheme['primary'] as Color;
    final secondary = scheme['secondary'] as Color;
    final accent = scheme['accent'] as Color;
    final darkBg = scheme['darkBg'] as Color;
    final darkSurface = scheme['darkSurface'] as Color;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: isDark ? darkSurface : lightSurface,
      background: isDark ? darkBg : lightBackground,
      onPrimary: Colors.white,
      onSecondary: isDark ? Colors.black : textDark,
      onSurface: isDark ? textLight : textDark,
      onBackground: isDark ? textLight : textDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Vazirmatn',
      scaffoldBackgroundColor: isDark ? darkBg : lightBackground,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkSurface : primary,
        foregroundColor: isDark ? secondary : Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? secondary : Colors.white,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? secondary : Colors.white,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        color: isDark ? darkSurface : lightSurface,
        elevation: 4,
        shadowColor: primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? secondary : primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? secondary : primary,
          side: BorderSide(color: isDark ? secondary : primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? secondary : primary,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          color: isDark ? textLight.withOpacity(0.7) : textDark.withOpacity(0.7),
        ),
      ),

      // TabBar
      tabBarTheme: TabBarTheme(
        labelColor: isDark ? secondary : Colors.white,
        unselectedLabelColor:
            (isDark ? textLight : Colors.white).withOpacity(0.6),
        indicatorColor: secondary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? darkSurface : Colors.grey.shade200,
        selectedColor: primary,
        labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? darkSurface : primary,
        contentTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          color: isDark ? textLight : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: isDark ? darkSurface : lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: (isDark ? textLight : textDark).withOpacity(0.1),
        thickness: 1,
      ),

      // Icon
      iconTheme: IconThemeData(
        color: isDark ? textLight : textDark,
      ),

      // Progress
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? secondary : primary,
      ),
    );
  }

  /// تم روشن پیش‌فرض (برای سازگاری با کدهای قدیمی)
  static final ThemeData lightTheme =
      getTheme(colorIndex: 0, brightness: Brightness.light);

  /// تم تاریک پیش‌فرض (برای سازگاری با کدهای قدیمی)
  static final ThemeData darkTheme =
      getTheme(colorIndex: 0, brightness: Brightness.dark);
}