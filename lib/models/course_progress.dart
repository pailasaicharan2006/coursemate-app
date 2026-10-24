class CourseProgress {
  final String id;
  final String userId;
  final String courseId;
  final int moduleIndex;
  final String moduleName;
  final bool isCompleted;
  final DateTime? completedAt;

  CourseProgress({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.moduleIndex,
    required this.moduleName,
    required this.isCompleted,
    this.completedAt,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      moduleIndex: json['module_index'],
      moduleName: json['module_name'],
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'module_index': moduleIndex,
      'module_name': moduleName,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
