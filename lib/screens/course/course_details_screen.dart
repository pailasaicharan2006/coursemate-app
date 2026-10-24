import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/course_provider.dart';
import 'package:coursemate_app/providers/learning_provider.dart';
import 'package:coursemate_app/widgets/course_illustration.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';

class CourseDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailsScreen> createState() =>
      _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  bool _startLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = AppTheme.darkBgMain;
    final textPrimary = AppTheme.darkTextPrimary;
    final textSecondary = AppTheme.darkTextSecondary;
    final accentCyan = AppTheme.cyanPrimary;
    final cardBg = AppTheme.darkCardBg;

    final user = ref.watch(currentUserProvider);
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final isSaved = ref.watch(isSavedProvider(widget.courseId));
    final userCourseAsync = ref.watch(userCourseProvider(widget.courseId));

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: courseAsync.when(
        data: (course) {
          if (course == null) {
            return Scaffold(
              backgroundColor: scaffoldBg,
              appBar: AppBar(
                backgroundColor: scaffoldBg,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: textPrimary),
                  onPressed: () => context.pop(),
                ),
              ),
              body: Center(
                child: Text('Course not found',
                    style: TextStyle(color: textSecondary)),
              ),
            );
          }

          // Determine enrolment state
          final userCourse = userCourseAsync.valueOrNull;
          final isEnrolled = userCourse != null;
          final isCompleted = userCourse?.status == 'completed';

          return CustomScrollView(
            slivers: [
              // ── App Bar with hero illustration ───────────────────────────
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                backgroundColor: scaffoldBg,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: textPrimary),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved
                          ? AppTheme.cyanPrimary
                          : textPrimary,
                    ),
                    onPressed: () async {
                      if (user == null) return;
                      try {
                        if (isSaved) {
                          await ref
                              .read(courseServiceProvider)
                              .unsaveCourse(user.id, course.id);
                        } else {
                          await ref
                              .read(courseServiceProvider)
                              .saveCourse(user.id, course.id);
                        }
                        ref.invalidate(savedCoursesProvider);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Action failed: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CourseIllustration(
                        category: course.category,
                        courseId: course.id,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              scaffoldBg.withAlpha(242),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Main content ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider + Match score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.business,
                                  color: Colors.grey, size: 20),
                              const SizedBox(width: 8),
                              Text(course.provider,
                                  style: TextStyle(
                                      color: textSecondary, fontSize: 16)),
                            ],
                          ),
                          if (course.matchScore > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.cyanPrimary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${course.matchScore.toInt()}% Match',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        course.title,
                        style: TextStyle(
                            color: textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text('${course.rating} (${course.reviewCount})',
                              style: TextStyle(color: textPrimary)),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time,
                              color: textSecondary, size: 18),
                          const SizedBox(width: 4),
                          Text('${course.durationHours.toInt()} hours',
                              style: TextStyle(color: textPrimary)),
                          const SizedBox(width: 16),
                          Icon(Icons.signal_cellular_alt,
                              color: textSecondary, size: 18),
                          const SizedBox(width: 4),
                          Text(course.difficulty,
                              style: TextStyle(color: textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Badges row: Free/Paid, Category, Enrolment status
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _badge(
                            text: course.isFree ? 'Free' : 'Paid',
                            bgColor: Colors.green.withAlpha(isDark ? 50 : 30),
                            textColor: Colors.green,
                          ),
                          _badge(
                            text: course.category,
                            bgColor: AppTheme.darkCardBg,
                            textColor: textPrimary,
                          ),
                          if (isEnrolled)
                            _badge(
                              icon: isCompleted
                                  ? Icons.check_circle
                                  : Icons.play_circle_outline,
                              text: isCompleted
                                  ? 'Completed'
                                  : 'In Progress',
                              bgColor: isCompleted
                                  ? Colors.green.withAlpha(isDark ? 40 : 25)
                                  : AppTheme.cyanPrimary.withAlpha(isDark ? 40 : 25),
                              textColor: isCompleted
                                  ? Colors.green
                                  : AppTheme.cyanPrimary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Visit Official Course button ──────────────────────
                      if (course.courseUrl.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.open_in_new,
                                size: 16, color: accentCyan),
                            label: Text(
                              'Visit Official Course',
                              style: TextStyle(
                                  color: accentCyan,
                                  fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: accentCyan),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            onPressed: () =>
                                _launchCourseUrl(course.courseUrl),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Opens the official provider website in your browser. '
                          'CourseMate tracks your progress independently.',
                          style: TextStyle(
                              color: textSecondary, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Course Overview ──────────────────────────────────
                      Text('Course Overview',
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF333344),
                            height: 1.5),
                      ),

                      // ── Skills ───────────────────────────────────────────
                      if (course.skills.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Skills You Will Learn',
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: course.skills
                              .map((s) => Chip(
                                    label: Text(s,
                                        style: TextStyle(
                                            color: isDark ? Colors.white : const Color(0xFF0288D1),
                                            fontSize: 12,
                                            fontWeight: isDark ? FontWeight.normal : FontWeight.w600)),
                                    backgroundColor:
                                        accentCyan.withAlpha(isDark ? 50 : 30),
                                    side: BorderSide.none,
                                  ))
                              .toList(),
                        ),
                      ],

                      // ── Prerequisites ────────────────────────────────────
                      if (course.prerequisites.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Prerequisites',
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...course.prerequisites.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: accentCyan, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(p,
                                        style: TextStyle(
                                            color: isDark ? Colors.white70 : const Color(0xFF333344)))),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ── Learning Outcomes ────────────────────────────────
                      if (course.learningOutcomes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text("What You'll Learn",
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...course.learningOutcomes.map(
                          (lo) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6.0),
                                  child: Icon(Icons.circle,
                                      color: AppTheme.cyanPrimary,
                                      size: 8),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(lo,
                                        style: TextStyle(
                                            color: isDark ? Colors.white70 : const Color(0xFF333344),
                                            height: 1.5))),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ── Curriculum ───────────────────────────────────────
                      if (course.curriculum.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Curriculum',
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...course.curriculum.asMap().entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(8),
                              border: isDark ? null : Border.all(color: const Color(0xFFE2E4ED)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      AppTheme.cyanPrimary.withAlpha(76),
                                  child: Text('${entry.key + 1}',
                                      style: TextStyle(
                                          color: isDark ? Colors.white : AppTheme.cyanPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(entry.value,
                                        style: TextStyle(
                                            color: textPrimary))),
                              ],
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.cyanPrimary)),
        error: (err, _) => Center(
            child: Text('Error loading course: $err',
                style: const TextStyle(color: Colors.redAccent))),
      ),

      // ── Bottom action bar: Ask AI | Start/Continue/View Progress ──────────
      bottomSheet: courseAsync.whenData((course) {
        if (course == null) return const SizedBox.shrink();

        final userCourse = userCourseAsync.valueOrNull;
        final isCompleted = userCourse?.status == 'completed';

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: isDark ? Colors.black26 : const Color(0xFFE2E4ED))),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Ask AI button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.push('/ai-chat?courseId=${widget.courseId}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentCyan,
                      side: BorderSide(color: accentCyan),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ask AI'),
                  ),
                ),
                const SizedBox(width: 12),

                // Start / Continue / View Progress button
                // This button ONLY navigates internally — never opens a URL.
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _startLoading
                        ? null
                        : () => _onStartOrContinue(userCourse != null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.green
                          : AppTheme.cyanPrimary,
                      disabledBackgroundColor:
                          AppTheme.cyanPrimary.withAlpha(128),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _startLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isCompleted)
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 16),
                              if (isCompleted) const SizedBox(width: 6),
                              Text(
                                isCompleted
                                    ? 'View Progress'
                                    : userCourse != null
                                        ? 'Continue Course'
                                        : 'Start Course',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).value ??
          const SizedBox.shrink(),
    );
  }

  // ── Start / Continue — ONLY navigates internally ────────────────────────
  Future<void> _onStartOrContinue(bool alreadyEnrolled) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please sign in to track your progress')),
      );
      return;
    }

    setState(() => _startLoading = true);

    try {
      if (!alreadyEnrolled) {
        await ref
            .read(learningServiceProvider)
            .startCourse(user.id, widget.courseId);
        ref.invalidate(userCourseProvider(widget.courseId));
        ref.invalidate(userCoursesLearningProvider);
      }

      if (!mounted) return;
      context.push('/course/${widget.courseId}/progress');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start course: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _startLoading = false);
    }
  }

  // ── Visit Official Course — ONLY opens external URL ─────────────────────
  Future<void> _launchCourseUrl(String courseUrl) async {
    if (courseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No official URL is set for this course.')),
      );
      return;
    }

    final uri = Uri.tryParse(courseUrl);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The course URL is invalid.')),
      );
      return;
    }

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Could not open the URL. Try visiting manually:\n$courseUrl')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open link: $e')),
        );
      }
    }
  }

  // ── Helper: coloured badge widget ───────────────────────────────────────
  Widget _badge({
    IconData? icon,
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
