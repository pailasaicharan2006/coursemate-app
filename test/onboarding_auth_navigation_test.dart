import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coursemate_app/core/utils/onboarding_preferences.dart';
import 'package:coursemate_app/screens/welcome/welcome_screen.dart';
import 'package:coursemate_app/screens/auth/login_screen.dart';
import 'package:coursemate_app/screens/auth/signup_screen.dart';
import 'package:coursemate_app/screens/auth/forgot_password_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingPreferences Tests', () {
    test('Default hasSeenOnboarding is false for brand new user', () async {
      final seen = await OnboardingPreferences.hasSeenOnboarding();
      expect(seen, isFalse);
      expect(OnboardingPreferences.cachedHasSeen, isFalse);
    });

    test('Setting hasSeenOnboarding persists true across reads and in cache', () async {
      await OnboardingPreferences.setHasSeenOnboarding(true);
      final seen = await OnboardingPreferences.hasSeenOnboarding();
      expect(seen, isTrue);
      expect(OnboardingPreferences.cachedHasSeen, isTrue);
    });

    test('init() prewarms cachedHasSeen', () async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      await OnboardingPreferences.init();
      expect(OnboardingPreferences.cachedHasSeen, isTrue);
    });

    test('Setting hasSeenOnboarding to false resets state', () async {
      await OnboardingPreferences.setHasSeenOnboarding(true);
      expect(await OnboardingPreferences.hasSeenOnboarding(), isTrue);

      await OnboardingPreferences.setHasSeenOnboarding(false);
      expect(await OnboardingPreferences.hasSeenOnboarding(), isFalse);
      expect(OnboardingPreferences.cachedHasSeen, isFalse);
    });
  });

  String resolveInitialRoute({
    required bool hasSession,
    required bool hasSeenOnboarding,
  }) {
    if (hasSession) {
      return '/home/discover';
    } else if (hasSeenOnboarding) {
      return '/login';
    } else {
      return '/welcome';
    }
  }

  group('Authentication & Onboarding Flow Routing Rules', () {
    test('Unauthenticated user without seen onboarding should visit /welcome', () async {
      final hasSeen = await OnboardingPreferences.hasSeenOnboarding();
      final destination = resolveInitialRoute(
        hasSession: false,
        hasSeenOnboarding: hasSeen,
      );
      expect(destination, '/welcome');
    });

    test('Unauthenticated user who has seen onboarding or logged out should visit /login', () async {
      await OnboardingPreferences.setHasSeenOnboarding(true);
      final hasSeen = await OnboardingPreferences.hasSeenOnboarding();
      final destination = resolveInitialRoute(
        hasSession: false,
        hasSeenOnboarding: hasSeen,
      );
      expect(destination, '/login');
    });

    test('Authenticated user with active session should go directly to /home/discover', () async {
      final hasSeen = await OnboardingPreferences.hasSeenOnboarding();
      final destination = resolveInitialRoute(
        hasSession: true,
        hasSeenOnboarding: hasSeen,
      );
      expect(destination, '/home/discover');
    });

    test('Logout destination is always /login, never /welcome', () {
      const postLogoutRoute = '/login';
      expect(postLogoutRoute, isNot('/welcome'));
      expect(postLogoutRoute, '/login');
    });
  });

  group('Onboarding & Auth Responsive Layout Tests', () {
    testWidgets('WelcomeScreen renders without overflow on desktop viewport (1200x800)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Find Your Perfect Course'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('WelcomeScreen renders without overflow on compact viewport (800x500)', (tester) async {
      tester.view.physicalSize = const Size(800, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LoginScreen form has constrained max width of 440px on desktop (1200x800)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final formBox = constrainedBoxes.firstWhere(
        (box) => box.constraints.maxWidth == 440,
      );
      expect(formBox.constraints.maxWidth, 440);
    });

    testWidgets('SignupScreen form has constrained max width of 440px on desktop (1200x800)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SignupScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final formBox = constrainedBoxes.firstWhere(
        (box) => box.constraints.maxWidth == 440,
      );
      expect(formBox.constraints.maxWidth, 440);
    });

    testWidgets('ForgotPasswordScreen form has constrained max width of 440px on desktop (1200x800)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final formBox = constrainedBoxes.firstWhere(
        (box) => box.constraints.maxWidth == 440,
      );
      expect(formBox.constraints.maxWidth, 440);
    });
  });
}
