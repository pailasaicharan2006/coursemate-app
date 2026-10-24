import 'course.dart';

class UserCourse {
  final String id;
  final String userId;
  final String courseId;
  final Course? course;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double progressPercent;

  UserCourse({
    required this.id,
    required this.userId,
    required this.courseId,
    this.course,
    required this.status,
    this.startedAt,
    this.completedAt,
    required this.progressPercent,
  });

  factory UserCourse.fromJson(Map<String, dynamic> json) {
    return UserCourse(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      courseId: json['course_id'] ?? (json['courses'] != null ? json['courses']['id'] : ''),
      course: (json['courses'] != null
          ? Course.fromJson(json['courses'])
          : (json['course'] != null ? Course.fromJson(json['course']) : null)),
      status: json['status'] ?? 'enrolled',
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      progressPercent: json['progress_percent'] != null ? (json['progress_percent'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'course': course?.toJson(),
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'progress_percent': progressPercent,
    };
  }

  UserCourse copyWith({
    String? id,
    String? userId,
    String? courseId,
    Course? course,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progressPercent,
  }) {
    return UserCourse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      course: course ?? this.course,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }
}
