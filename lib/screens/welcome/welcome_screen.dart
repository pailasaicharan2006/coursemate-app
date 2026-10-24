import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/core/utils/onboarding_preferences.dart';
import 'package:coursemate_app/core/widgets/coursemate_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySeen();
  }

  Future<void> _checkIfAlreadySeen() async {
    final seen = await OnboardingPreferences.hasSeenOnboarding();
    if (seen && mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildPage(
                        title: 'Find Your Perfect Course',
                        subtitle: 'Personalized learning for your career',
                        icon: Icons.search_rounded,
                      ),
                      _buildPage(
                        title: 'Courses tailored to you',
                        subtitle: 'Tell us your interests and get personalized recommendations',
                        icon: Icons.recommend_rounded,
                      ),
                      _buildPage(
                        title: 'Track your progress',
                        subtitle: 'Monitor your learning journey and achieve your goals',
                        icon: Icons.trending_up_rounded,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppTheme.cyanPrimary
                                  : AppTheme.darkBorderCyan,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.cyanPrimary.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_currentPage == 2)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              await OnboardingPreferences.setHasSeenOnboarding(true);
                              if (context.mounted) context.go('/signup');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cyanPrimary,
                              foregroundColor: const Color(0xFF050A0D),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                await OnboardingPreferences.setHasSeenOnboarding(true);
                                if (context.mounted) context.go('/login');
                              },
                              child: const Text(
                                'Skip',
                                style: TextStyle(color: AppTheme.darkTextSecondary, fontSize: 16),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 52,
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.cyanPrimary,
                                  foregroundColor: const Color(0xFF050A0D),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          await OnboardingPreferences.setHasSeenOnboarding(true);
                          if (context.mounted) context.go('/login');
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: AppTheme.darkTextSecondary),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: AppTheme.cyanPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isCompact = availableHeight < 520;
        final illustrationHeight = isCompact ? 150.0 : 190.0;
        final spacing = isCompact ? 18.0 : 28.0;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CourseMateLogo(
                    height: 38,
                    forceDark: true,
                  ),
                  SizedBox(height: spacing),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 360),
                    height: illustrationHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.darkCardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.darkBorderCyan),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.cyanPrimary.withValues(alpha: 0.10),
                          AppTheme.darkCardBg,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cyanPrimary.withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: isCompact ? 88 : 104,
                        height: isCompact ? 88 : 104,
                        decoration: BoxDecoration(
                          color: AppTheme.cyanPrimary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.cyanPrimary.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: isCompact ? 46 : 56,
                          color: AppTheme.cyanPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isCompact ? 22 : 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.darkTextSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
