import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode';
  static const _kPalette = 'palette_index';

  ThemeMode _mode = ThemeMode.system;
  int _palette = 0;

  ThemeMode get mode => _mode;
  int get palette => _palette;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeController() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final m = prefs.getString(_kThemeMode);
    _mode = m == 'dark'
        ? ThemeMode.dark
        : m == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    _palette = prefs.getInt(_kPalette) ?? 0;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kThemeMode, mode.name);
  }

  Future<void> toggle() async {
    await setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setPalette(int i) async {
    _palette = i;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kPalette, i);
  }

  ThemeData themeFor(Brightness b) =>
      AppThemes.buildTheme(paletteIndex: _palette, brightness: b);
}