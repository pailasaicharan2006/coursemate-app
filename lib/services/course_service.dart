import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/models/course.dart';
import 'package:coursemate_app/models/saved_course.dart';
import 'package:coursemate_app/models/user_course.dart';

class CourseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Course>> getAllCourses() async {
    try {
      final response = await _supabase.from('courses').select();
      return (response as List).map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch courses: $e');
    }
  }

  Future<Course?> getCourseById(String id) async {
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return Course.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch course: $e');
    }
  }

  Future<List<Course>> getCoursesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .eq('category', category);
      return (response as List).map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch courses by category: $e');
    }
  }

  Future<List<Course>> searchCourses(String query, {Map<String, dynamic>? filters}) async {
    try {
      var dbQuery = _supabase.from('courses').select().ilike('title', '%$query%');
      
      if (filters != null) {
        if (filters.containsKey('level')) {
          dbQuery = dbQuery.eq('level', filters['level']);
        }
        if (filters.containsKey('category')) {
          dbQuery = dbQuery.eq('category', filters['category']);
        }
      }
      
      final response = await dbQuery;
      return (response as List).map((e) => Course.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to search courses: $e');
    }
  }

  Future<void> saveCourse(String userId, String courseId) async {
    try {
      await _supabase.from('saved_courses').insert({
        'user_id': userId,
        'course_id': courseId,
      });
    } catch (e) {
      throw Exception('Failed to save course: $e');
    }
  }

  Future<void> unsaveCourse(String userId, String courseId) async {
    try {
      await _supabase
          .from('saved_courses')
          .delete()
          .eq('user_id', userId)
          .eq('course_id', courseId);
    } catch (e) {
      throw Exception('Failed to unsave course: $e');
    }
  }

  Future<List<SavedCourse>> getSavedCourses(String userId) async {
    try {
      final response = await _supabase
          .from('saved_courses')
          .select('*, courses(*)')
          .eq('user_id', userId);
      return (response as List).map((e) => SavedCourse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch saved courses: $e');
    }
  }

  Future<bool> isSaved(String userId, String courseId) async {
    try {
      final response = await _supabase
          .from('saved_courses')
          .select('id')
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Failed to check if course is saved: $e');
    }
  }

  Future<void> enrollCourse(String userId, String courseId) async {
    try {
      await _supabase.from('user_courses').insert({
        'user_id': userId,
        'course_id': courseId,
        'status': 'enrolled',
      });
    } catch (e) {
      throw Exception('Failed to enroll in course: $e');
    }
  }

  Future<List<UserCourse>> getUserCourses(String userId) async {
    try {
      final response = await _supabase
          .from('user_courses')
          .select('*, courses(*)')
          .eq('user_id', userId);
      return (response as List).map((e) => UserCourse.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user courses: $e');
    }
  }

  Future<void> updateCourseStatus(String userId, String courseId, String status) async {
    try {
      await _supabase
          .from('user_courses')
          .update({'status': status})
          .eq('user_id', userId)
          .eq('course_id', courseId);
    } catch (e) {
      throw Exception('Failed to update course status: $e');
    }
  }
}
