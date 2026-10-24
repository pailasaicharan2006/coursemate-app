import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/core/utils/onboarding_preferences.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/theme_provider.dart';
import 'package:coursemate_app/screens/splash_screen.dart';
import 'package:coursemate_app/screens/welcome/welcome_screen.dart';
import 'package:coursemate_app/screens/auth/login_screen.dart';
import 'package:coursemate_app/screens/auth/signup_screen.dart';
import 'package:coursemate_app/screens/auth/forgot_password_screen.dart';
import 'package:coursemate_app/screens/onboarding/profile_setup_screen.dart';
import 'package:coursemate_app/screens/onboarding/interest_selection_screen.dart';
import 'package:coursemate_app/screens/onboarding/skill_selection_screen.dart';
import 'package:coursemate_app/screens/onboarding/learning_goals_screen.dart';
import 'package:coursemate_app/screens/home/discover_screen.dart';
import 'package:coursemate_app/screens/home/saved_screen.dart';
import 'package:coursemate_app/screens/home/schedule_screen.dart';
import 'package:coursemate_app/screens/home/profile_screen.dart';
import 'package:coursemate_app/screens/course/course_details_screen.dart';
import 'package:coursemate_app/screens/course/course_progress_screen.dart';
import 'package:coursemate_app/screens/notifications/notifications_screen.dart';
import 'package:coursemate_app/screens/settings/settings_screen.dart';
import 'package:coursemate_app/screens/ai_chat/ai_chat_screen.dart';
import 'package:coursemate_app/screens/profile/edit_profile_screen.dart';
import 'package:coursemate_app/screens/search/search_screen.dart';
import 'package:coursemate_app/screens/learning/certificates_locker_screen.dart';
import 'package:coursemate_app/screens/learning/courses_in_progress_screen.dart';
import 'package:coursemate_app/screens/learning/completed_courses_screen.dart';
import 'package:coursemate_app/widgets/main_scaffold.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDiscoverKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellDiscover');
final _shellNavigatorSavedKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSaved');
final _shellNavigatorScheduleKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSchedule');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(supabaseClientProvider).auth.onAuthStateChange;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authStream),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/interests',
        builder: (context, state) => const InterestSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/skills',
        builder: (context, state) => const SkillSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/goals',
        builder: (context, state) => const LearningGoalsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDiscoverKey,
            routes: [
              GoRoute(
                path: '/home/discover',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSavedKey,
            routes: [
              GoRoute(
                path: '/home/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorScheduleKey,
            routes: [
              GoRoute(
                path: '/home/schedule',
                builder: (context, state) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailsScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/course/:id/progress',
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseProgressScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          final conversationId = state.uri.queryParameters['conversationId'];
          return AiChatScreen(courseId: courseId, conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/learning/in-progress',
        builder: (context, state) => const CoursesInProgressScreen(),
      ),
      GoRoute(
        path: '/learning/completed',
        builder: (context, state) => const CompletedCoursesScreen(),
      ),
      GoRoute(
        path: '/certificates',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          final courseTitle = state.uri.queryParameters['courseTitle'];
          return CertificatesLockerScreen(
            initialCourseId: courseId,
            initialCourseTitle: courseTitle,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAtSplash = location == '/';
      final isAuthRoute = location.startsWith('/welcome') ||
          location.startsWith('/login') ||
          location.startsWith('/signup') ||
          location.startsWith('/forgot-password');

      final user = ref.read(currentUserProvider) ?? Supabase.instance.client.auth.currentUser;

      if (user == null) {
        if (isAtSplash) return null; // allow splash screen to check session and route
        if (location == '/welcome' && OnboardingPreferences.cachedHasSeen == true) {
          return '/login';
        }
        if (isAuthRoute) return null; // allow login, signup, welcome, forgot-password
        // When session is lost or user logs out, send them directly to login, never onboarding
        return '/login';
      }

      // If user is already authenticated and attempts to access auth pages or welcome walkthrough,
      // redirect them straight to discover
      if (isAuthRoute) {
        return '/home/discover';
      }

      return null;
    },
  );
});

class CourseMateApp extends ConsumerWidget {
  const CourseMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'CourseMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
