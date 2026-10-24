import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier to manage and persist the application's ThemeMode.
/// Defaults to [ThemeMode.dark] for existing and first-time users.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefKey = 'coursemate_theme_mode';

  ThemeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_prefKey);
      if (savedTheme == 'light') {
        state = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        state = ThemeMode.dark;
      } else {
        // Default to dark theme as required
        state = ThemeMode.dark;
      }
    } catch (_) {
      state = ThemeMode.dark;
    }
  }

  /// Toggles between dark mode (true) and light mode (false).
  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, isDark ? 'dark' : 'light');
    } catch (_) {}
  }

  /// Sets the theme mode directly.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKey,
        mode == ThemeMode.light ? 'light' : 'dark',
      );
    } catch (_) {}
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
