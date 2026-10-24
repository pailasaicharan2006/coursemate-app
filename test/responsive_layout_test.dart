import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coursemate_app/models/course.dart';
import 'package:coursemate_app/widgets/course_card.dart';
import 'package:coursemate_app/widgets/course_illustration.dart';

void main() {
  final testCourse = Course(
    id: '4dcd49fd-7589-4d8c-a37d-ee04a8835450',
    title: 'IBM Data Science Professional Certificate',
    provider: 'IBM',
    description: 'Learn data science fundamentals',
    category: 'Data Science',
    difficulty: 'Beginner',
    durationHours: 40.0,
    rating: 4.8,
    reviewCount: 1250,
    skills: ['Python', 'SQL', 'Data Science'],
    interests: ['Data Science'],
    prerequisites: [],
    learningOutcomes: ['Data analysis', 'Machine learning'],
    curriculum: ['Module 1', 'Module 2'],
    courseUrl: 'https://coursera.org',
    imageUrl: '',
    isFree: false,
    createdAt: DateTime.now(),
    matchScore: 95.0,
  );

  group('Responsive Layout Tests', () {
    testWidgets('CourseCard renders 16:9 AspectRatio and CourseIllustration',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: CourseCard(
                course: testCourse,
                onViewDetails: () {},
              ),
            ),
          ),
        ),
      );

      final aspectRatioFinder = find.byType(AspectRatio);
      expect(aspectRatioFinder, findsOneWidget);

      final AspectRatio aspectRatioWidget = tester.widget(aspectRatioFinder);
      expect(aspectRatioWidget.aspectRatio, closeTo(16 / 9, 0.001));

      expect(find.byType(CourseIllustration), findsOneWidget);
      expect(find.text('IBM Data Science Professional Certificate'), findsOneWidget);
      expect(find.text('IBM'), findsOneWidget);
      expect(find.text('Data Science'), findsOneWidget);
      expect(find.text('95% Match'), findsOneWidget);
    });

    testWidgets('CourseCard renders cleanly at desktop width (1200x800) without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 380, // Approximate 3-column item width in 1200px container
                child: CourseCard(
                  course: testCourse,
                  onViewDetails: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('IBM Data Science Professional Certificate'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('CourseCard renders cleanly at mobile width (390x844) without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CourseCard(
                course: testCourse,
                onViewDetails: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('IBM Data Science Professional Certificate'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });
  });
}
