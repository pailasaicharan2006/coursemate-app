import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/models/course_progress.dart';
import 'package:coursemate_app/models/user_course.dart';
import 'package:coursemate_app/models/study_session.dart';

class LearningService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // Enrol / start a course — idempotent (INSERT … ON CONFLICT DO NOTHING)
  // Does NOT overwrite an existing record so a completed status is preserved.
  // ---------------------------------------------------------------------------
  Future<void> startCourse(String userId, String courseId) async {
    try {
      await _supabase.from('user_courses').upsert(
        {
          'user_id': userId,
          'course_id': courseId,
          'status': 'in_progress',
          'progress_percent': 0.0,
          'started_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,course_id',
        ignoreDuplicates: true,
      );
    } catch (e) {
      throw Exception('Failed to start course: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Toggle a single module's completion and persist to Supabase.
  // Returns the new isCompleted value so callers can update local state.
  // After saving, synchronises user_courses.progress_percent and status.
  // ---------------------------------------------------------------------------
  Future<void> updateProgress(
    String userId,
    String courseId,
    int moduleIndex,
    String moduleName,
    bool isCompleted,
  ) async {
    // Upsert the module row.
    // course_progress has columns: id, user_id, course_id, module_index,
    // module_name, is_completed, completed_at
    // It has a UNIQUE constraint on (user_id, course_id, module_index).
    await _supabase.from('course_progress').upsert(
      {
        'user_id': userId,
        'course_id': courseId,
        'module_index': moduleIndex,
        'module_name': moduleName,
        'is_completed': isCompleted,
        'completed_at':
            isCompleted ? DateTime.now().toIso8601String() : null,
      },
      onConflict: 'user_id,course_id,module_index',
    );
    // Note: we intentionally do NOT call _recalculateProgress here.
    // The screen calls recalculateProgressWithTotal explicitly after this
    // so we avoid a double fetch of the curriculum length.
  }

  // ---------------------------------------------------------------------------
  // Recalculate progress_percent in user_courses from course_progress rows.
  // totalModules is passed in so we avoid an extra round-trip.
  // ---------------------------------------------------------------------------
  Future<void> recalculateProgressWithTotal(
    String userId,
    String courseId,
    int totalModules,
  ) async {
    final rows = await _supabase
        .from('course_progress')
        .select('is_completed')
        .eq('user_id', userId)
        .eq('course_id', courseId);

    final completedCount =
        (rows as List).where((r) => r['is_completed'] == true).length;

    final percent = totalModules > 0
        ? (completedCount / totalModules * 100.0).clamp(0.0, 100.0)
        : 0.0;

    final allDone = totalModules > 0 && completedCount >= totalModules;

    final Map<String, dynamic> update = {
      'progress_percent': percent,
      'status': allDone ? 'completed' : 'in_progress',
    };
    if (allDone) {
      update['completed_at'] = DateTime.now().toIso8601String();
    } else {
      // Ensure completed_at is cleared if modules were unchecked
      update['completed_at'] = null;
    }

    await _supabase
        .from('user_courses')
        .update(update)
        .eq('user_id', userId)
        .eq('course_id', courseId);
  }

  // ---------------------------------------------------------------------------
  // Fetch module-level progress for a specific course (ordered by index)
  // ---------------------------------------------------------------------------
  Future<List<CourseProgress>> getCourseProgress(
      String userId, String courseId) async {
    final response = await _supabase
        .from('course_progress')
        .select()
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .order('module_index', ascending: true);
    return (response as List).map((e) => CourseProgress.fromJson(e)).toList();
  }

  // ---------------------------------------------------------------------------
  // Get a single user_course record (used to check enrolment status)
  // ---------------------------------------------------------------------------
  Future<UserCourse?> getUserCourse(String userId, String courseId) async {
    final response = await _supabase
        .from('user_courses')
        .select('*, courses(*)')
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .maybeSingle();
    if (response == null) return null;
    return UserCourse.fromJson(response);
  }

  // ---------------------------------------------------------------------------
  // Fetch all enrolled courses for My Learning screen
  // ---------------------------------------------------------------------------
  Future<List<UserCourse>> getUserCourses(String userId) async {
    final response = await _supabase
        .from('user_courses')
        .select('*, courses(*)')
        .eq('user_id', userId)
        .order('started_at', ascending: false);
    return (response as List).map((e) => UserCourse.fromJson(e)).toList();
  }

  // ---------------------------------------------------------------------------
  // Study sessions (table is study_schedule in schema)
  // ---------------------------------------------------------------------------
  Future<void> addStudySession(StudySession session) async {
    await _supabase.from('study_schedule').insert({
      'user_id': session.userId,
      'course_id': session.courseId,
      'scheduled_date':
          session.scheduledDate.toIso8601String().split('T')[0],
      'scheduled_time': session.scheduledTime,
      'duration_minutes': session.durationMinutes,
      'is_completed': session.isCompleted,
    });
  }

  Future<List<StudySession>> getStudySessions(String userId) async {
    final response = await _supabase
        .from('study_schedule')
        .select('*, courses(*)')
        .eq('user_id', userId)
        .order('scheduled_date', ascending: true);
    return (response as List).map((e) => StudySession.fromJson(e)).toList();
  }

  Future<void> completeStudySession(String sessionId) async {
    await _supabase
        .from('study_schedule')
        .update({'is_completed': true}).eq('id', sessionId);
  }

  Future<void> markCourseComplete(String userId, String courseId) async {
    await _supabase
        .from('user_courses')
        .update({
          'status': 'completed',
          'progress_percent': 100.0,
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('course_id', courseId);
  }

  Future<void> removeFromLearning(String userId, String courseId) async {
    try {
      await _supabase
          .from('user_courses')
          .delete()
          .eq('user_id', userId)
          .eq('course_id', courseId);
    } catch (e) {
      throw Exception('Failed to remove course from learning: $e');
    }
  }
}
