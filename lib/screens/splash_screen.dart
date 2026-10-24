import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/core/utils/onboarding_preferences.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/core/widgets/coursemate_logo.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // 1. Check if user is already authenticated with a valid session
    final user = ref.read(currentUserProvider) ?? Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      // Existing session -> restore authenticated app directly without showing onboarding!
      try {
        final profileService = ProfileService();
        final hasCompleted = await profileService.hasCompletedOnboarding(user.id);
        if (!mounted) return;
        if (hasCompleted) {
          context.go('/home/discover');
        } else {
          context.go('/onboarding/profile');
        }
      } catch (_) {
        if (mounted) context.go('/home/discover');
      }
      return;
    }

    // 2. Unauthenticated user: Brief splash branding display
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Check again in case auth state resolved during the initial moment
    final resolvedUser = ref.read(currentUserProvider) ?? Supabase.instance.client.auth.currentUser;
    if (resolvedUser != null) {
      if (mounted) context.go('/home/discover');
      return;
    }

    // 3. Check whether user has already seen onboarding or logged out
    final hasSeenOnboarding = await OnboardingPreferences.hasSeenOnboarding();
    if (!mounted) return;
    if (hasSeenOnboarding) {
      context.go('/login');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkBgSecondary,
              AppTheme.darkBgMain,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CourseMateLogo(
                height: 72,
                forceDark: true,
              ),
              const SizedBox(height: 22),
              Container(
                width: 50,
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.cyanPrimary, AppTheme.cyanSecondary],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x6620DDF5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Master your skills',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.darkTextSecondary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
