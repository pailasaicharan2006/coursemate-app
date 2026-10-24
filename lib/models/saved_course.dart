import 'course.dart';

class SavedCourse {
  final String id;
  final String userId;
  final String courseId;
  final Course? course;
  final DateTime savedAt;

  SavedCourse({
    required this.id,
    required this.userId,
    required this.courseId,
    this.course,
    required this.savedAt,
  });

  factory SavedCourse.fromJson(Map<String, dynamic> json) {
    return SavedCourse(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      courseId: json['course_id'] ?? (json['courses'] != null ? json['courses']['id'] : ''),
      course: (json['courses'] != null
          ? Course.fromJson(json['courses'])
          : (json['course'] != null ? Course.fromJson(json['course']) : null)),
      savedAt: json['saved_at'] != null ? DateTime.parse(json['saved_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'course': course?.toJson(),
      'saved_at': savedAt.toIso8601String(),
    };
  }
}
