import 'package:flutter/material.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/models/course.dart';
import 'package:coursemate_app/widgets/course_illustration.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onSave;
  final VoidCallback? onUnsave;
  final bool isSaved;
  final VoidCallback onViewDetails;
  final bool showMatchScore;
  final double? matchScore;
  final EdgeInsetsGeometry? margin;

  /// @deprecated This flag is no longer needed; all cards now use the unified
  /// black-and-cyan design. The parameter is accepted for backward compatibility
  /// but has no visual effect.
  // ignore: unused_element
  final bool cyanStyle;

  const CourseCard({
    super.key,
    required this.course,
    this.onSave,
    this.onUnsave,
    this.isSaved = false,
    required this.onViewDetails,
    this.showMatchScore = true,
    this.matchScore,
    this.margin,
    this.cyanStyle = true, // kept for API compatibility
  });

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF22C55E);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.darkTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMatchScore = matchScore ?? course.matchScore;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorderCyan),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanPrimary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails,
          hoverColor: AppTheme.cyanPrimary.withValues(alpha: 0.06),
          splashColor: AppTheme.cyanPrimary.withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 16:9 Thumbnail with overlays
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CourseIllustration(
                      category: course.category,
                      courseId: course.id,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay for badge legibility
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.25),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBgMain.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.cyanPrimary.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          course.category,
                          style: const TextStyle(
                            color: AppTheme.cyanPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Match score badge
                    if (showMatchScore && effectiveMatchScore > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.cyanPrimary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.cyanPrimary.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${effectiveMatchScore.toInt()}% Match',
                            style: const TextStyle(
                              color: Color(0xFF050A0D),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.darkTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Provider
                    Text(
                      course.provider,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.darkTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Meta row: rating | duration | difficulty
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 3),
                        Text(
                          '${course.rating}',
                          style: const TextStyle(
                            color: AppTheme.darkTextPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded,
                            color: AppTheme.darkTextSecondary, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${course.durationHours.toInt()}h',
                          style: const TextStyle(
                            color: AppTheme.darkTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(course.difficulty)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            course.difficulty,
                            style: TextStyle(
                              color: _getDifficultyColor(course.difficulty),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Action row: bookmark | view details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isSaved
                                ? AppTheme.cyanPrimary
                                : AppTheme.darkTextSecondary,
                            size: 22,
                          ),
                          onPressed: isSaved ? onUnsave : onSave,
                          tooltip: isSaved
                              ? 'Remove bookmark'
                              : 'Bookmark course',
                        ),
                        TextButton.icon(
                          onPressed: onViewDetails,
                          icon: const Icon(Icons.arrow_forward_rounded,
                              size: 15,
                              color: AppTheme.cyanPrimary),
                          label: const Text(
                            'View Details',
                            style: TextStyle(
                              color: AppTheme.cyanPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
