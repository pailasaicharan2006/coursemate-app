import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coursemate_app/models/course_progress.dart';
import 'package:coursemate_app/models/study_session.dart';
import 'package:coursemate_app/models/user_course.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/services/learning_service.dart';
import 'package:coursemate_app/models/certificate.dart';
import 'package:coursemate_app/services/certificate_service.dart';

final learningServiceProvider = Provider<LearningService>((ref) {
  return LearningService();
});

final studySessionsProvider = FutureProvider<List<StudySession>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(learningServiceProvider).getStudySessions(user.id);
});

final userCoursesLearningProvider = FutureProvider<List<UserCourse>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(learningServiceProvider).getUserCourses(user.id);
});

final courseProgressProvider =
    FutureProvider.family<List<CourseProgress>, String>((ref, courseId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(learningServiceProvider).getCourseProgress(user.id, courseId);
});

/// Checks enrolment status for a single course.
/// Returns null if the user has not started the course.
final userCourseProvider =
    FutureProvider.family<UserCourse?, String>((ref, courseId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(learningServiceProvider).getUserCourse(user.id, courseId);
});

final certificateServiceProvider = Provider<CertificateService>((ref) {
  return CertificateService();
});

final certificatesProvider = FutureProvider<List<Certificate>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(certificateServiceProvider).getCertificates(user.id);
});

