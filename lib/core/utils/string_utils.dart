import 'package:flutter/material.dart';

class StringUtils {
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String formatDuration(double hours) {
    int totalMinutes = (hours * 60).round();
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    if (h > 0 && m > 0) {
      return '${h}h ${m}m';
    } else if (h > 0) {
      return '${h}h';
    } else {
      return '${m}m';
    }
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static Color difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50); // Success green
      case 'intermediate':
        return const Color(0xFFFFC107); // Warning yellow
      case 'advanced':
        return const Color(0xFFFF5252); // Error red
      default:
        return const Color(0xFF6C63FF); // Primary purple
    }
  }

  static IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'data science':
      case 'data analytics':
        return Icons.analytics;
      case 'artificial intelligence':
      case 'machine learning':
        return Icons.psychology;
      case 'web development':
        return Icons.language;
      case 'mobile development':
        return Icons.smartphone;
      case 'cybersecurity':
        return Icons.security;
      case 'cloud computing':
        return Icons.cloud;
      case 'ui/ux design':
        return Icons.design_services;
      case 'programming':
        return Icons.code;
      default:
        return Icons.library_books;
    }
  }
}
