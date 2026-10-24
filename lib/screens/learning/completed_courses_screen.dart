import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/models/certificate.dart';
import 'package:coursemate_app/providers/learning_provider.dart';
import 'package:coursemate_app/widgets/course_illustration.dart';

class CompletedCoursesScreen extends ConsumerWidget {
  const CompletedCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCoursesAsync  = ref.watch(userCoursesLearningProvider);
    final certificatesAsync = ref.watch(certificatesProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Completed Courses',
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
          final completedCourses =
              courses.where((c) => c.status == 'completed').toList();

          if (completedCourses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emoji_events_outlined,
                          size: 64, color: AppTheme.success),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Completed Courses Yet',
                      style: TextStyle(
                          color: AppTheme.darkTextPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Finish modules and track your milestones. Once completed, your achievements appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.darkTextSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/home/discover'),
                      child: const Text('Browse Courses'),
                    ),
                  ],
                ),
              ),
            );
          }

          final certificates = certificatesAsync.value ?? <Certificate>[];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userCoursesLearningProvider);
              ref.invalidate(certificatesProvider);
            },
            color: AppTheme.cyanPrimary,
            backgroundColor: AppTheme.darkCardBg,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: completedCourses.length,
              itemBuilder: (context, index) {
                final userCourse = completedCourses[index];
                final course     = userCourse.course;
                final title      = course?.title    ?? 'Completed Course';
                final provider   = course?.provider ?? 'CourseMate';
                final category   = course?.category ?? 'Programming';

                final linkedCert = certificates
                    .where((cert) =>
                        cert.courseId == userCourse.courseId ||
                        (cert.courseTitle != null &&
                            cert.courseTitle!.trim().toLowerCase() ==
                                title.trim().toLowerCase()))
                    .firstOrNull;

                final completedDateStr = userCourse.completedAt != null
                    ? DateFormat('MMM d, yyyy')
                        .format(userCourse.completedAt!)
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkBorderCyan),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CourseIllustration(
                              category: category,
                              courseId: userCourse.courseId,
                              width: 68,
                              height: 68,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle,
                                              size: 12,
                                              color: AppTheme.success),
                                          SizedBox(width: 4),
                                          Text('Completed',
                                              style: TextStyle(
                                                  color: AppTheme.success,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    if (completedDateStr != null) ...[
                                      const SizedBox(width: 8),
                                      Text(completedDateStr,
                                          style: const TextStyle(
                                              color: AppTheme.darkTextSecondary,
                                              fontSize: 11)),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(title,
                                    style: const TextStyle(
                                        color: AppTheme.darkTextPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(provider,
                                    style: const TextStyle(
                                        color: AppTheme.darkTextSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(
                          color: AppTheme.darkBorderCyan, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              final id =
                                  course?.id ?? userCourse.courseId;
                              context.push('/course/$id');
                            },
                            icon: const Icon(Icons.info_outline,
                                size: 16),
                            label: const Text('Course Info'),
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    AppTheme.darkTextSecondary),
                          ),
                          if (linkedCert != null)
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.push('/certificates'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                              ),
                              icon: const Icon(
                                  Icons.workspace_premium,
                                  size: 16),
                              label: const Text('View Certificate',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () {
                                final cid =
                                    course?.id ?? userCourse.courseId;
                                context.push(
                                  Uri(
                                    path: '/certificates',
                                    queryParameters: {
                                      'courseId': cid,
                                      'courseTitle': title,
                                    },
                                  ).toString(),
                                );
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Certificate',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
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
}
