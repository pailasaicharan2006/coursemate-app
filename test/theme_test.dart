import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeMode & Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeNotifier defaults to ThemeMode.dark when no preference is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = ThemeNotifier();
      // Initial state is ThemeMode.dark
      expect(notifier.state, equals(ThemeMode.dark));

      // Wait for any microtasks/async init
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(notifier.state, equals(ThemeMode.dark));
    });

    test('ThemeNotifier restores light mode when "light" is stored in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'coursemate_theme_mode': 'light'});
      final notifier = ThemeNotifier();

      // Wait for _loadTheme() async completion
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(notifier.state, equals(ThemeMode.light));
    });

    test('ThemeNotifier restores dark mode when "dark" is stored in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'coursemate_theme_mode': 'dark'});
      final notifier = ThemeNotifier();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(notifier.state, equals(ThemeMode.dark));
    });

    test('toggleTheme toggles between light and dark modes and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = ThemeNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Toggle to light
      await notifier.toggleTheme(false);
      expect(notifier.state, equals(ThemeMode.light));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('coursemate_theme_mode'), equals('light'));

      // Toggle back to dark
      await notifier.toggleTheme(true);
      expect(notifier.state, equals(ThemeMode.dark));
      expect(prefs.getString('coursemate_theme_mode'), equals('dark'));
    });

    test('setThemeMode explicitly updates state and persists mode', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = ThemeNotifier();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, equals(ThemeMode.light));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('coursemate_theme_mode'), equals('light'));

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, equals(ThemeMode.dark));
      expect(prefs.getString('coursemate_theme_mode'), equals('dark'));
    });
  });

  group('AppTheme Configuration Tests', () {
    test('darkTheme has expected dark palette properties', () {
      final darkTheme = AppTheme.darkTheme;

      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.scaffoldBackgroundColor, equals(AppTheme.darkBgMain));
      expect(darkTheme.colorScheme.primary, equals(AppTheme.cyanPrimary));
      expect(darkTheme.colorScheme.secondary, equals(AppTheme.cyanSecondary));
      expect(darkTheme.cardTheme.color, equals(AppTheme.darkCardBg));
    });

    test('lightTheme has expected light palette properties', () {
      final lightTheme = AppTheme.lightTheme;

      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.scaffoldBackgroundColor, equals(AppTheme.lightBg));
      expect(lightTheme.colorScheme.primary, equals(AppTheme.cyanSecondary));
      expect(lightTheme.cardTheme.color, equals(AppTheme.lightCardBg));
    });

    test('Brand colors match specifications across modes', () {
      // Cyan palette (replacing old purple)
      expect(AppTheme.cyanPrimary,   equals(const Color(0xFF20DDF5)));
      expect(AppTheme.cyanSecondary, equals(const Color(0xFF168FE5)));

      // Dark background tokens
      expect(AppTheme.darkBgMain,      equals(const Color(0xFF050A0D)));
      expect(AppTheme.darkBgSecondary, equals(const Color(0xFF071318)));
      expect(AppTheme.darkCardBg,      equals(const Color(0xFF0B171D)));

      // Light bg
      expect(AppTheme.lightBg,     equals(const Color(0xFFF0F4F8)));
      expect(AppTheme.lightCardBg, equals(Colors.white));

      // Deprecated aliases still resolve to cyan
      expect(AppTheme.primaryPurple, equals(AppTheme.cyanPrimary));
      expect(AppTheme.accentCyan,    equals(AppTheme.cyanSecondary));
    });
  });
}
