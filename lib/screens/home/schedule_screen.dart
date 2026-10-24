import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/models/certificate.dart';
import 'package:coursemate_app/models/user_course.dart';
import 'package:coursemate_app/providers/learning_provider.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCoursesAsync  = ref.watch(userCoursesLearningProvider);
    final certificatesAsync = ref.watch(certificatesProvider);

    final userCourses  = userCoursesAsync.value  ?? <UserCourse>[];
    final certificates = certificatesAsync.value ?? <Certificate>[];

    final inProgressCourses = userCourses
        .where((c) => c.status == 'in_progress' || c.status == 'enrolled')
        .toList();
    final completedCourses =
        userCourses.where((c) => c.status == 'completed').toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Learning Hub',
          style: TextStyle(
            color: AppTheme.darkTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppTheme.cyanPrimary),
            tooltip: 'Ask Atom',
            onPressed: () => context.push('/ai-chat'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: AppTheme.darkTextSecondary),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userCoursesLearningProvider);
          ref.invalidate(certificatesProvider);
        },
        color: AppTheme.cyanPrimary,
        backgroundColor: AppTheme.darkCardBg,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dashboard banner ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.cyanPrimary.withValues(alpha: 0.12),
                      AppTheme.cyanSecondary.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.darkBorderCyan),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cyanPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.space_dashboard_rounded,
                        size: 28,
                        color: AppTheme.cyanPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Learning Dashboard',
                            style: TextStyle(
                              color: AppTheme.darkTextPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage active courses, achievements, and certificates.',
                            style: TextStyle(
                              color: AppTheme.darkTextSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Hub Categories',
                style: TextStyle(
                  color: AppTheme.darkTextPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Card 1: Courses In Progress
              _buildHubCard(
                context: context,
                title: 'Courses In Progress',
                count: inProgressCourses.length,
                countUnit: inProgressCourses.length == 1
                    ? 'Course'
                    : 'Courses',
                description:
                    'Active enrollments with module tracking & progress',
                icon: Icons.school_outlined,
                accentColor: AppTheme.cyanPrimary,
                onTap: () => context.push('/learning/in-progress'),
              ),
              const SizedBox(height: 16),

              // Card 2: Completed Courses
              _buildHubCard(
                context: context,
                title: 'Completed Courses',
                count: completedCourses.length,
                countUnit:
                    completedCourses.length == 1 ? 'Course' : 'Courses',
                description:
                    'Your completed courses and verified milestones',
                icon: Icons.emoji_events_outlined,
                accentColor: AppTheme.success,
                onTap: () => context.push('/learning/completed'),
              ),
              const SizedBox(height: 16),

              // Card 3: Certificates Locker
              _buildHubCard(
                context: context,
                title: 'Certificates Locker',
                count: certificates.length,
                countUnit: certificates.length == 1
                    ? 'Certificate'
                    : 'Certificates',
                description:
                    'Digital certificates, PDF uploads & credentials',
                icon: Icons.workspace_premium_outlined,
                accentColor: AppTheme.cyanSecondary,
                onTap: () => context.push('/certificates'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHubCard({
    required BuildContext context,
    required String title,
    required int count,
    required String countUnit,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: AppTheme.cyanPrimary.withValues(alpha: 0.04),
        splashColor: AppTheme.cyanPrimary.withValues(alpha: 0.06),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.darkCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorderCyan),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cyanPrimary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppTheme.darkTextPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppTheme.darkTextSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.darkTextSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
