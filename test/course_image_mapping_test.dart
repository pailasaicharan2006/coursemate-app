import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:coursemate_app/core/constants/course_images.dart';
import 'package:coursemate_app/widgets/course_illustration.dart';

void main() {
  group('CourseImageMapping Tests', () {
    test('Verified courses return mapped asset paths across all batches', () {
      // Batch 1
      expect(
        CourseImageMapping.getAssetForCourse(
            '4dcd49fd-7589-4d8c-a37d-ee04a8835450'),
        'assets/images/courses/ibm_data_science.png',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'ecfe386e-524c-4705-a281-404dc926e9a6'),
        'assets/images/courses/google_data_analytics.png',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            '51d46f05-6065-442a-876c-194876381df4'),
        'assets/images/courses/google_ux_design.png',
      );

      // Batch 2
      expect(
        CourseImageMapping.getAssetForCourse(
            '4aadb278-d6c0-44ef-b06b-371179ae5255'),
        'assets/images/courses/google_cybersecurity.png',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            '5efb247a-5ca8-42c2-b98a-f4198ef324d4'),
        'assets/images/courses/prompt_engineering_dlai.png',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'cb8a2ec8-ec3d-4e4c-9413-c871fe55a89f'),
        'assets/images/courses/docker_and_kubernetes.jpg',
      );

      // Batch 3
      expect(
        CourseImageMapping.getAssetForCourse(
            '986cc7d3-774f-4c96-b4c2-44d8ea320502'),
        'assets/images/courses/android_basics_udacity.jpg',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'b11bc701-e5d9-4861-a0f2-f44240cb77e3'),
        'assets/images/courses/flutter_firebase_bizzotto.png',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'de9c81ec-ad94-470e-a64d-3059806c9caa'),
        'assets/images/courses/react_complete_guide_max.jpg',
      );

      // Batch 4 (Final 10)
      expect(
        CourseImageMapping.getAssetForCourse(
            '6fc53725-32b9-49ce-988f-8576514ebdf7'),
        'assets/images/courses/ai_ethics_harvard.webp',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'f3574c95-a6fa-420d-98f6-2d247a090f1f'),
        'assets/images/courses/applied_data_science_python_umich.jpg',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            '909cf35c-196c-4713-be80-867a9288561d'),
        'assets/images/courses/aws_cloud_practitioner_essentials.jpg',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'fe803939-9b62-4259-939f-857add93635b'),
        'assets/images/courses/elements_of_ai.png',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            '0d111478-8cc3-4926-85df-869b77b565df'),
        'assets/images/courses/full_stack_open.jpg',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            '75e3c8c7-d9cd-4a6e-915d-4cc7fca94fb0'),
        'assets/images/courses/intro_to_sql_khan.jpg',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            '4177487b-e6d2-4f7c-9ce9-b5cd1447d6f2'),
        'assets/images/courses/cisco_intro_to_cybersecurity.png',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'cdf1d3ee-b828-456f-ad18-e272b76be7f5'),
        'assets/images/courses/statistics_probability_khan.jpg',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'fe75510d-81c3-4df0-84a1-03e566514ad6'),
        'assets/images/courses/complete_javascript_jonas.jpg',
      );
      expect(
        CourseImageMapping.getAssetForCourse(
            'ba5b7b2a-0997-41f3-8cb9-959546f55900'),
        'assets/images/courses/ui_design_fundamentals_scrimba.jpg',
      );
    });

    test('All 44 courses in catalog have dedicated thumbnails mapped', () {
      expect(CourseImageMapping.courseThumbnailAssets.length, 44);
    });

    test('Unmapped or null courseId returns null for SVG fallback', () {
      expect(CourseImageMapping.getAssetForCourse(null), isNull);
      expect(
        CourseImageMapping.getAssetForCourse('unknown-or-unverified-course-id'),
        isNull,
      );
    });

    test('Every mapped asset file (all 44) exists on disk and is non-empty', () {
      for (final entry in CourseImageMapping.courseThumbnailAssets.entries) {
        final file = File(entry.value);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Asset file ${entry.value} for course ${entry.key} must exist on disk',
        );
        expect(
          file.lengthSync(),
          greaterThan(1000),
          reason: 'Asset file ${entry.value} must be a valid non-empty image',
        );
      }
    });

    test('CourseIllustration accentFor returns valid colors for categories', () {
      expect(CourseIllustration.accentFor('Data Science'), isNotNull);
      expect(CourseIllustration.accentFor('Machine Learning'), isNotNull);
      expect(CourseIllustration.accentFor('Programming'), isNotNull);
    });
  });
}
