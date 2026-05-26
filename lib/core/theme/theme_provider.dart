import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Provider for managing app theme mode (light/dark/system).
/// Persists selection to SharedPreferences.
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider({required SharedPreferences prefs}) : _prefs = prefs {
    _loadTheme();
  }

  void _loadTheme() {
    final themeIndex =
        _prefs.getInt(AppConstants.themeKey) ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setInt(AppConstants.themeKey, mode.index);
  }

  /// Returns the display name key for current theme.
  String get themeDisplayKey {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'theme_light';
      case ThemeMode.dark:
        return 'theme_dark';
      case ThemeMode.system:
        return 'theme_system';
    }
  }

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isSystem => _themeMode == ThemeMode.system;
}
