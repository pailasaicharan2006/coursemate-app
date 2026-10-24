class ChatConversation {
  final String id;
  final String userId;
  final String title;
  final String? courseId;
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.title,
    this.courseId,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      courseId: json['course_id'],
      lastMessage: json['last_message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'course_id': courseId,
      'last_message': lastMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
