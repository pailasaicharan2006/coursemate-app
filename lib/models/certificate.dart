class Certificate {
  final String id;
  final String userId;
  final String? courseId;
  final String? courseTitle;
  final String title;
  final String issuer;
  final DateTime? issueDate;
  final String? fileUrl;
  final String? storagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Certificate({
    required this.id,
    required this.userId,
    this.courseId,
    this.courseTitle,
    required this.title,
    required this.issuer,
    this.issueDate,
    this.fileUrl,
    this.storagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      courseId: json['course_id']?.toString(),
      courseTitle: json['course_title']?.toString(),
      title: json['title']?.toString() ?? 'Certificate',
      issuer: json['issuer']?.toString() ?? '',
      issueDate: json['issue_date'] != null
          ? DateTime.tryParse(json['issue_date'].toString())
          : null,
      fileUrl: json['file_url']?.toString(),
      storagePath: json['storage_path']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'course_title': courseTitle,
      'title': title,
      'issuer': issuer,
      'issue_date': issueDate != null
          ? "${issueDate!.year.toString().padLeft(4, '0')}-${issueDate!.month.toString().padLeft(2, '0')}-${issueDate!.day.toString().padLeft(2, '0')}"
          : null,
      'file_url': fileUrl,
      'storage_path': storagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Certificate copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? courseTitle,
    String? title,
    String? issuer,
    DateTime? issueDate,
    String? fileUrl,
    String? storagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Certificate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      title: title ?? this.title,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      fileUrl: fileUrl ?? this.fileUrl,
      storagePath: storagePath ?? this.storagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
