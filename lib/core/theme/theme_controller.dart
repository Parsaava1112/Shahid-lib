// lib/core/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'color_scheme_index';

  ThemeMode _themeMode = ThemeMode.system;
  int _colorIndex = 0;

  ThemeMode get themeMode => _themeMode;
  int get colorIndex => _colorIndex;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Color get primaryColor =>
      AppThemeColors.colorSchemes[_colorIndex]['primary']!;
  Color get secondaryColor =>
      AppThemeColors.colorSchemes[_colorIndex]['secondary']!;

  ThemeController() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    }
    _colorIndex = prefs.getInt(_colorKey) ?? 0;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> setColorIndex(int index) async {
    _colorIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, index);
  }

  /// ساخت تم پویا بر اساس رنگ انتخابی
  ThemeData getTheme(Brightness brightness) {
    final scheme = AppThemeColors.colorSchemes[_colorIndex];
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: scheme['primary']!,
        brightness: brightness,
        secondary: scheme['secondary'],
        tertiary: scheme['accent'],
      ),
      fontFamily: 'Vazirmatn',
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0D1B0E) : const Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? const Color(0xFF1A2E1B)
            : scheme['primary'],
        foregroundColor: isDark ? scheme['secondary'] : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: isDark ? const Color(0xFF1A2E1B) : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? scheme['secondary'] : scheme['primary'],
          foregroundColor: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2E1B) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}