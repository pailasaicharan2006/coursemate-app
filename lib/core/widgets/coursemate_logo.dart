import 'package:flutter/material.dart';

/// Renders the official CourseMate logo with the open-book + AI symbol
/// and the 'CourseMate' wordmark. Automatically selects the dark or light
/// variant based on the current theme brightness unless explicitly overridden.
class CourseMateLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool? forceDark;
  final bool? forceLight;

  const CourseMateLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.forceDark,
    this.forceLight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = forceDark == true
        ? true
        : forceLight == true
            ? false
            : Theme.of(context).brightness == Brightness.dark;

    final assetPath = isDark
        ? 'assets/images/logo_dark.png'
        : 'assets/images/logo_light.png';

    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
      semanticLabel: 'CourseMate Logo',
    );
  }
}

/// Renders just the official CourseMate open-book + AI node symbol.
class CourseMateSymbol extends StatelessWidget {
  final double? size;
  final BoxFit fit;

  const CourseMateSymbol({
    super.key,
    this.size,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_symbol.png',
      width: size,
      height: size,
      fit: fit,
      semanticLabel: 'CourseMate Symbol',
    );
  }
}
