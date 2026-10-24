import 'course.dart';

class StudySession {
  final String id;
  final String userId;
  final String courseId;
  final Course? course;
  final DateTime scheduledDate;
  final String scheduledTime;
  final int durationMinutes;
  final bool isCompleted;

  StudySession({
    required this.id,
    required this.userId,
    required this.courseId,
    this.course,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.isCompleted,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      course: json['course'] != null ? Course.fromJson(json['course']) : null,
      scheduledDate: DateTime.parse(json['scheduled_date']),
      scheduledTime: json['scheduled_time'],
      durationMinutes: json['duration_minutes'],
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'course': course?.toJson(),
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time': scheduledTime,
      'duration_minutes': durationMinutes,
      'is_completed': isCompleted,
    };
  }
}
