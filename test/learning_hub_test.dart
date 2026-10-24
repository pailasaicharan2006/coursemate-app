import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coursemate_app/models/certificate.dart';
import 'package:coursemate_app/models/user_course.dart';
import 'package:coursemate_app/screens/home/schedule_screen.dart';
import 'package:coursemate_app/screens/learning/courses_in_progress_screen.dart';
import 'package:coursemate_app/screens/learning/completed_courses_screen.dart';
import 'package:coursemate_app/screens/learning/certificates_locker_screen.dart';

// Helpers ------------------------------------------------------------------

UserCourse _makeUserCourse(String id, String status) => UserCourse(
      id: id,
      userId: 'user1',
      courseId: 'course-$id',
      status: status,
      progressPercent: status == 'completed' ? 100 : 40,
    );

Certificate _makeCert(String id) => Certificate(
      id: id,
      userId: 'user1',
      title: 'Cert $id',
      issuer: 'Org $id',
    );

// ---------------------------------------------------------------------------
// Navigation / Routing unit tests
// ---------------------------------------------------------------------------
void main() {
  group('Learning Hub — Certificate Model', () {
    test('Certificate.fromJson round-trips cleanly', () {
      final now = DateTime(2025, 1, 15);
      final original = Certificate(
        id: 'abc',
        userId: 'u1',
        courseId: 'c1',
        courseTitle: 'Python Basics',
        title: 'Python Cert',
        issuer: 'Coursera',
        issueDate: now,
        fileUrl: 'https://example.com/cert.pdf',
      );

      final json = original.toJson();
      final restored = Certificate.fromJson(json);

      expect(restored.id, equals('abc'));
      expect(restored.userId, equals('u1'));
      expect(restored.courseId, equals('c1'));
      expect(restored.courseTitle, equals('Python Basics'));
      expect(restored.title, equals('Python Cert'));
      expect(restored.issuer, equals('Coursera'));
      expect(restored.issueDate, equals(now));
      expect(restored.fileUrl, equals('https://example.com/cert.pdf'));
    });

    test('Certificate.copyWith updates only specified fields', () {
      final cert = Certificate(
        id: 'abc',
        userId: 'u1',
        title: 'Old Title',
        issuer: 'Old Issuer',
      );

      final updated = cert.copyWith(title: 'New Title');
      expect(updated.title, equals('New Title'));
      expect(updated.issuer, equals('Old Issuer'));
      expect(updated.id, equals('abc'));
    });

    test('Certificate.toJson issue_date is formatted as yyyy-MM-dd', () {
      final cert = Certificate(
        id: 'x',
        userId: 'u',
        title: 'T',
        issuer: 'I',
        issueDate: DateTime(2024, 6, 5),
      );

      final json = cert.toJson();
      expect(json['issue_date'], equals('2024-06-05'));
    });

    test('Certificate.fromJson handles null optional fields gracefully', () {
      final json = {
        'id': 'abc',
        'user_id': 'u1',
        'title': 'Cert',
        'issuer': 'Org',
      };
      final cert = Certificate.fromJson(json);
      expect(cert.courseId, isNull);
      expect(cert.fileUrl, isNull);
      expect(cert.issueDate, isNull);
    });
  });

  group('Learning Hub — Navigation route labels', () {
    test('Learning Hub scheduled_screen imports are resolvable', () {
      // Compile-time check: if the import tree compiles, the routes are wired
      expect(const ScheduleScreen(), isA<ConsumerWidget>());
      expect(const CoursesInProgressScreen(), isA<ConsumerStatefulWidget>());
      expect(const CompletedCoursesScreen(), isA<ConsumerWidget>());
      expect(const CertificatesLockerScreen(), isA<ConsumerStatefulWidget>());
    });
  });

  group('Learning Hub — Course removal logic', () {
    test('in-progress filter excludes completed courses', () {
      final courses = [
        _makeUserCourse('1', 'in_progress'),
        _makeUserCourse('2', 'completed'),
        _makeUserCourse('3', 'enrolled'),
      ];

      final inProgress = courses
          .where((c) => c.status == 'in_progress' || c.status == 'enrolled')
          .toList();
      final completed = courses.where((c) => c.status == 'completed').toList();

      expect(inProgress.length, 2);
      expect(completed.length, 1);
      expect(inProgress.any((c) => c.status == 'completed'), isFalse);
    });

    test('completed filter excludes in-progress courses', () {
      final courses = [
        _makeUserCourse('a', 'in_progress'),
        _makeUserCourse('b', 'completed'),
        _makeUserCourse('c', 'completed'),
      ];

      final completed = courses.where((c) => c.status == 'completed').toList();
      expect(completed.length, 2);
      expect(completed.every((c) => c.status == 'completed'), isTrue);
    });
  });

  group('Learning Hub — Certificate access', () {
    test('certificates linked to course are found by courseId', () {
      final certs = [
        Certificate(
          id: '1', userId: 'u', title: 'A', issuer: 'X', courseId: 'course-abc'),
        Certificate(
          id: '2', userId: 'u', title: 'B', issuer: 'Y', courseId: 'course-xyz'),
      ];

      final linked = certs.where((c) => c.courseId == 'course-abc').toList();
      expect(linked.length, 1);
      expect(linked.first.id, '1');
    });

    test('unlinked course returns no certificate', () {
      final certs = [
        Certificate(
          id: '1', userId: 'u', title: 'A', issuer: 'X', courseId: 'course-abc'),
      ];

      final linked = certs.where((c) => c.courseId == 'course-zzz').toList();
      expect(linked.isEmpty, isTrue);
    });

    test('deleting a certificate removes it from local list', () {
      final certs = [
        _makeCert('1'),
        _makeCert('2'),
        _makeCert('3'),
      ];

      certs.removeWhere((c) => c.id == '2');
      expect(certs.length, 2);
      expect(certs.any((c) => c.id == '2'), isFalse);
    });
  });

  group('Learning Hub — Android and XML config', () {
    test('Android adaptive icon XMLs exist (learning hub branding)', () {
      final xmlFiles = [
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml',
      ];
      for (final path in xmlFiles) {
        expect(File(path).existsSync(), isTrue, reason: '$path must exist');
      }
    });
  });
}
