import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/models/user_course.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/learning_provider.dart';
import 'package:coursemate_app/widgets/course_illustration.dart';

class CoursesInProgressScreen extends ConsumerWidget {
  const CoursesInProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCoursesAsync = ref.watch(userCoursesLearningProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Courses In Progress',
          style: TextStyle(
              color: AppTheme.darkTextPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppTheme.darkTextSecondary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: userCoursesAsync.when(
        data: (courses) {
          final inProgressCourses = courses
              .where((c) =>
                  c.status == 'in_progress' || c.status == 'enrolled')
              .toList();

          if (inProgressCourses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cyanPrimary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_outlined,
                          size: 64, color: AppTheme.cyanPrimary),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Courses In Progress',
                      style: TextStyle(
                          color: AppTheme.darkTextPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore our wide selection of courses and start learning today.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.darkTextSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/home/discover'),
                      child: const Text('Discover Courses'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userCoursesLearningProvider),
            color: AppTheme.cyanPrimary,
            backgroundColor: AppTheme.darkCardBg,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: inProgressCourses.length,
              itemBuilder: (context, index) {
                final userCourse = inProgressCourses[index];
                final course    = userCourse.course;
                final title     = course?.title    ?? 'Enrolled Course';
                final provider  = course?.provider ?? 'CourseMate';
                final category  = course?.category ?? 'Programming';
                final progress  =
                    (userCourse.progressPercent / 100.0).clamp(0.0, 1.0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkBorderCyan),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CourseIllustration(
                          category: category,
                          courseId: userCourse.courseId,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                        color: AppTheme.darkTextPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      color: AppTheme.darkTextSecondary,
                                      size: 20),
                                  color: AppTheme.darkCardBg,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  onSelected: (value) {
                                    if (value == 'remove') {
                                      _confirmRemoveCourse(
                                          context, ref, userCourse, title);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Row(
                                        children: [
                                          Icon(
                                              Icons.remove_circle_outline,
                                              size: 18,
                                              color: Colors.redAccent),
                                          SizedBox(width: 8),
                                          Text('Remove from Learning',
                                              style: TextStyle(
                                                  color: Colors.redAccent)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(provider,
                                style: const TextStyle(
                                    color: AppTheme.darkTextSecondary,
                                    fontSize: 12)),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: AppTheme.darkBorderSubtle,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppTheme.cyanPrimary),
                                minHeight: 5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(progress * 100).toInt()}% complete',
                                  style: const TextStyle(
                                      color: AppTheme.darkTextSecondary,
                                      fontSize: 12),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final id =
                                        course?.id ?? userCourse.courseId;
                                    context.push('/course/$id/progress');
                                  },
                                  child: const Text(
                                    'Continue →',
                                    style: TextStyle(
                                        color: AppTheme.cyanPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.cyanPrimary)),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: AppTheme.darkTextSecondary)),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveCourse(
    BuildContext context,
    WidgetRef ref,
    UserCourse userCourse,
    String courseTitle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Remove from Learning?'),
        content: Text(
          'Are you sure you want to remove "$courseTitle" from your active learning?\n\n'
          '• This only removes your personal active enrollment.\n'
          '• Your current active progress for this course will be cleared.\n'
          '• Completed courses, certificates, and the course catalog will not be affected.\n'
          '• You can freely re-enroll at any time from Discover.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      try {
        await ref
            .read(learningServiceProvider)
            .removeFromLearning(user.id, userCourse.courseId);
        ref.invalidate(userCoursesLearningProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Removed "$courseTitle" from learning.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to remove: $e'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }
}
