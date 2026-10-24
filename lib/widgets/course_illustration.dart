import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:coursemate_app/core/constants/course_images.dart';

/// Renders a course image.
/// If [courseId] has a verified official thumbnail in [CourseImageMapping],
/// it displays that local image asset.
/// Otherwise, it maps [category] to the bundled category SVG asset.
/// Falls back to a gradient placeholder if neither is available.
class CourseIllustration extends StatelessWidget {
  final String category;
  final String? courseId;
  final double? height;
  final double? width;
  final BoxFit fit;

  const CourseIllustration({
    super.key,
    required this.category,
    this.courseId,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  static const Map<String, String> _categoryToAsset = {
    'Artificial Intelligence': 'assets/illustrations/ai.svg',
    'Machine Learning':        'assets/illustrations/ml.svg',
    'Data Science':            'assets/illustrations/data_science.svg',
    'Data Analytics':          'assets/illustrations/data_analytics.svg',
    'Programming':             'assets/illustrations/programming.svg',
    'Cloud Computing':         'assets/illustrations/cloud.svg',
    'Cybersecurity':           'assets/illustrations/cybersecurity.svg',
    'Mobile Development':      'assets/illustrations/mobile.svg',
    'UI/UX Design':            'assets/illustrations/uiux.svg',
    'Web Development':         'assets/illustrations/web.svg',
  };

  /// Returns the accent colour associated with the category for the gradient
  /// fallback and the shimmer tint.
  static Color accentFor(String category) {
    switch (category) {
      case 'Artificial Intelligence':
      case 'Machine Learning':
        return const Color(0xFF6C63FF);
      case 'Data Science':
      case 'Data Analytics':
        return const Color(0xFF4FC3F7);
      case 'Programming':
        return const Color(0xFF28C840);
      case 'Cloud Computing':
        return const Color(0xFF4FC3F7);
      case 'Cybersecurity':
        return const Color(0xFF6C63FF);
      case 'Mobile Development':
        return const Color(0xFF4FC3F7);
      case 'UI/UX Design':
        return const Color(0xFFA78BFA);
      case 'Web Development':
        return const Color(0xFF6C63FF);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Check if course has a verified local thumbnail asset
    final localAsset = CourseImageMapping.getAssetForCourse(courseId);
    if (localAsset != null) {
      return Image.asset(
        localAsset,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildSvgOrPlaceholder();
        },
      );
    }

    // 2. Otherwise fall back to the category SVG illustration
    return _buildSvgOrPlaceholder();
  }

  Widget _buildSvgOrPlaceholder() {
    final assetPath = _categoryToAsset[category];

    if (assetPath == null) {
      // Unknown category — gradient placeholder
      return _GradientPlaceholder(
        height: height,
        width: width,
        color: accentFor(category),
        label: category,
      );
    }

    return SvgPicture.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
      placeholderBuilder: (_) => _GradientPlaceholder(
        height: height,
        width: width,
        color: accentFor(category),
        label: category,
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  final double? height;
  final double? width;
  final Color color;
  final String label;

  const _GradientPlaceholder({
    this.height,
    this.width,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(60),
            const Color(0xFF1A1A2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.school, color: color.withAlpha(180), size: 40),
      ),
    );
  }
}
