import 'package:flutter/material.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/course_provider.dart';
import 'package:coursemate_app/providers/learning_provider.dart';

class CourseProgressScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseProgressScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseProgressScreen> createState() =>
      _CourseProgressScreenState();
}

class _CourseProgressScreenState extends ConsumerState<CourseProgressScreen> {
  // ── Optimistic local state ───────────────────────────────────────────────
  // Key   = moduleIndex
  // Value = current completion state (toggled immediately on tap)
  // Initialised from server data the FIRST time data loads; thereafter
  // updated locally so the UI responds instantly without waiting for a round-trip.
  Map<int, bool>? _localCompletions;

  // Tracks which module indices currently have a save in-flight
  final Set<int> _saving = {};

  // Whether we have ever initialised _localCompletions from server data
  bool _initialised = false;

  // ── Initialise local state from Supabase on first load ──────────────────
  void _initFromServer(List<dynamic> progressList) {
    if (_initialised) return;
    _initialised = true;
    _localCompletions = {
      for (final p in progressList) p.moduleIndex: p.isCompleted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = AppTheme.darkBgMain;
    final textPrimary = AppTheme.darkTextPrimary;
    final textSecondary = AppTheme.darkTextSecondary;
    final accentCyan = isDark ? AppTheme.cyanSecondary : const Color(0xFF0288D1);
    final cardBg = AppTheme.darkCardBg;

    final user = ref.watch(currentUserProvider);
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final progressAsync = ref.watch(courseProgressProvider(widget.courseId));

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Course Progress',
          style: TextStyle(
              color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: courseAsync.when(
        data: (course) {
          if (course == null) {
            return const Center(
              child: Text('Course not found',
                  style: TextStyle(color: Colors.grey)),
            );
          }

          // Use the real DB curriculum; fall back only when truly empty
          final curriculum = course.curriculum.isNotEmpty
              ? course.curriculum
              : [
                  'Module 1: Introduction & Fundamentals',
                  'Module 2: Core Concepts & Practice',
                  'Module 3: Advanced Topics & Hands-on',
                  'Module 4: Final Capstone Project',
                ];
          final totalModules = curriculum.length;

          return progressAsync.when(
            data: (progressList) {
              // Initialise local state from server on first load
              _initFromServer(progressList);

              // Merge: start from server data, overlay any local overrides
              final serverMap = <int, bool>{
                for (final p in progressList) p.moduleIndex: p.isCompleted,
              };
              // After initialisation, use localCompletions as source of truth
              final completions = _localCompletions ?? serverMap;

              final completedCount =
                  completions.values.where((v) => v).length;
              final percent = totalModules > 0
                  ? (completedCount / totalModules).clamp(0.0, 1.0)
                  : 0.0;
              final allDone =
                  totalModules > 0 && completedCount >= totalModules;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Course title
                    Text(
                      course.title,
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // ── Progress ring ────────────────────────────────────
                    CircularPercentIndicator(
                      radius: 75.0,
                      lineWidth: 12.0,
                      percent: percent,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(percent * 100).toInt()}%',
                            style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 26),
                          ),
                          Text('Complete',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 12)),
                        ],
                      ),
                      progressColor: allDone
                          ? Colors.green
                          : AppTheme.cyanPrimary,
                      backgroundColor: AppTheme.darkCardBg,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(height: 24),

                    // ── Stats row ────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('Modules', '$completedCount/$totalModules', textPrimary, textSecondary),
                        _stat('Duration',
                            '${course.durationHours.toInt()}h', textPrimary, textSecondary),
                        _stat('Status',
                            allDone ? 'Completed' : 'In Progress', textPrimary, textSecondary),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Overall progress bar ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: isDark ? null : Border.all(color: const Color(0xFFE2E4ED)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Overall Progress',
                                  style: TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.bold)),
                              Text('${(percent * 100).toInt()}%',
                                  style: TextStyle(
                                      color: accentCyan,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: percent,
                            backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFE2E4ED),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              allDone
                                  ? Colors.green
                                  : AppTheme.cyanPrimary,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Completion banner ────────────────────────────────
                    if (allDone)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.green.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events,
                                color: Colors.amber, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Course Completed! 🎉',
                                      style: TextStyle(
                                          color: textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'You have finished all modules.',
                                      style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 12)),
                                  if (course.courseUrl.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () =>
                                          _launch(course.courseUrl),
                                      child: Text(
                                          'Visit course website →',
                                          style: TextStyle(
                                              color: accentCyan,
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Module list ──────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Curriculum Modules',
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),

                    ...curriculum.asMap().entries.map((entry) {
                      final index = entry.key;
                      final name = entry.value;

                      // Source of truth: local optimistic state
                      final isCompleted =
                          completions[index] ?? false;
                      final isSaving = _saving.contains(index);

                      return _ModuleTile(
                        key: ValueKey('module_${widget.courseId}_$index'),
                        moduleName: name,
                        moduleIndex: index,
                        isCompleted: isCompleted,
                        isSaving: isSaving,
                        onToggle: user == null
                            ? null
                            : () => _toggle(
                                  user.id,
                                  index,
                                  name,
                                  !isCompleted,
                                  totalModules,
                                ),
                      );
                    }),

                    const SizedBox(height: 32),

                    // ── Open official site ───────────────────────────────
                    if (course.courseUrl.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.open_in_new,
                              color: accentCyan, size: 16),
                          label: Text('Open on Official Website',
                              style:
                                  TextStyle(color: accentCyan)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: accentCyan),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                          onPressed: () => _launch(course.courseUrl),
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
            loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.cyanPrimary)),
            error: (err, _) => Center(
                child: Text('Error loading progress: $err',
                    style: const TextStyle(color: Colors.redAccent))),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.cyanPrimary)),
        error: (err, _) => Center(
            child: Text('Error loading course: $err',
                style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  // ── Toggle a module ────────────────────────────────────────────────────
  Future<void> _toggle(
    String userId,
    int index,
    String moduleName,
    bool newCompleted,
    int totalModules,
  ) async {
    if (_saving.contains(index)) return; // prevent double-tap

    // 1. Optimistic update — instant visual feedback
    setState(() {
      _localCompletions ??= {};
      _localCompletions![index] = newCompleted;
      _saving.add(index);
    });

    try {
      final svc = ref.read(learningServiceProvider);

      // 2. Persist module completion
      await svc.updateProgress(
        userId,
        widget.courseId,
        index,
        moduleName,
        newCompleted,
      );

      // 3. Recalculate + persist progress_percent and status in user_courses
      await svc.recalculateProgressWithTotal(
        userId,
        widget.courseId,
        totalModules,
      );

      // 4. Refresh providers so My Learning and Course Details stay in sync
      ref.invalidate(courseProgressProvider(widget.courseId));
      ref.invalidate(userCoursesLearningProvider);
      ref.invalidate(userCourseProvider(widget.courseId));
    } catch (e) {
      // 5. Revert optimistic update on failure
      if (mounted) {
        setState(() {
          _localCompletions![index] = !newCompleted; // revert
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(index));
    }
  }

  // ── Launch URL ─────────────────────────────────────────────────────────
  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── Stat widget ────────────────────────────────────────────────────────
  Widget _stat(String label, String value, Color textPrimary, Color textSecondary) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: textSecondary, fontSize: 12)),
        ],
      );
}

// ── Extracted module tile widget ──────────────────────────────────────────
// Extracted so each tile has a stable ValueKey and doesn't rebuild siblings.
class _ModuleTile extends StatelessWidget {
  final String moduleName;
  final int moduleIndex;
  final bool isCompleted;
  final bool isSaving;
  final VoidCallback? onToggle;

  const _ModuleTile({
    super.key,
    required this.moduleName,
    required this.moduleIndex,
    required this.isCompleted,
    required this.isSaving,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.darkTextPrimary;
    final cardBg = AppTheme.darkCardBg;
    final borderLight = isDark ? null : const Color(0xFFE2E4ED);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withAlpha(100)
              : (borderLight ?? Colors.transparent),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // ── Left indicator: completion status ─────────────────────────
        leading: isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.cyanPrimary),
              )
            : Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: isCompleted ? Colors.green : Colors.grey,
                size: 26,
              ),

        // ── Module name ───────────────────────────────────────────────
        title: Text(
          moduleName,
          style: TextStyle(
            color: isCompleted ? textPrimary.withAlpha(153) : textPrimary,
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: textPrimary.withAlpha(96),
          ),
        ),

        // ── Right action button ───────────────────────────────────────
        // Hidden while saving to prevent double-tap
        trailing: isSaving
            ? null
            : _ActionButton(
                isCompleted: isCompleted,
                onToggle: onToggle,
              ),
      ),
    );
  }
}

// ── Action button (mark done / undo) ─────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onToggle;

  const _ActionButton({
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.grey.withAlpha(40)
              : AppTheme.cyanPrimary.withAlpha(40),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted
                ? Colors.grey.withAlpha(80)
                : AppTheme.cyanPrimary.withAlpha(120),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.undo_rounded : Icons.check_rounded,
              size: 14,
              color: isCompleted ? Colors.grey : AppTheme.cyanPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              isCompleted ? 'Undo' : 'Mark Done',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.grey : AppTheme.cyanPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
