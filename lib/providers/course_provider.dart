import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coursemate_app/models/course.dart';
import 'package:coursemate_app/models/saved_course.dart';
import 'package:coursemate_app/models/user_course.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/services/course_service.dart';
import 'package:coursemate_app/services/recommendation_service.dart';

final courseServiceProvider = Provider<CourseService>((ref) {
  return CourseService();
});

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService();
});

final allCoursesProvider = FutureProvider<List<Course>>((ref) async {
  return ref.read(courseServiceProvider).getAllCourses();
});

final recommendedCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(recommendationServiceProvider).getRecommendations(user.id);
});

final courseDetailProvider = FutureProvider.family<Course?, String>((ref, id) async {
  return ref.read(courseServiceProvider).getCourseById(id);
});

final savedCoursesProvider = FutureProvider<List<SavedCourse>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(courseServiceProvider).getSavedCourses(user.id);
});

final isSavedProvider = Provider.family<bool, String>((ref, courseId) {
  final savedCoursesAsync = ref.watch(savedCoursesProvider);
  return savedCoursesAsync.maybeWhen(
    data: (courses) => courses.any((c) => c.courseId == courseId),
    orElse: () => false,
  );
});

final userCoursesProvider = FutureProvider<List<UserCourse>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(courseServiceProvider).getUserCourses(user.id);
});

class CourseFilter {
  final String category;
  CourseFilter({required this.category});
}

final courseFilterProvider = StateProvider<CourseFilter?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');
