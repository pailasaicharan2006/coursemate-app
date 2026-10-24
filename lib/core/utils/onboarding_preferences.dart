import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistence of whether the initial 3-page onboarding walkthrough
/// has been seen by the user.
class OnboardingPreferences {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static bool? _cachedHasSeen;

  /// Synchronously returns whether the user has already seen onboarding
  /// (available after [init] or [hasSeenOnboarding]).
  static bool? get cachedHasSeen => _cachedHasSeen;

  /// Pre-warms the cache during app startup to avoid asynchronous routing delay.
  static Future<bool> init() async {
    return hasSeenOnboarding();
  }

  /// Returns true if the user has already seen or completed the welcome onboarding walkthrough.
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool(_keyHasSeenOnboarding) ?? false;
      _cachedHasSeen = seen;
      return seen;
    } catch (_) {
      return _cachedHasSeen ?? false;
    }
  }

  /// Sets whether the onboarding walkthrough has been seen.
  static Future<void> setHasSeenOnboarding(bool seen) async {
    _cachedHasSeen = seen;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenOnboarding, seen);
    } catch (_) {}
  }
}
