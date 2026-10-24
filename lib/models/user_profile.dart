class UserProfile {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? avatarUrl;
  final String educationLevel;
  final String fieldOfStudy;
  final String currentYear;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.educationLevel,
    required this.fieldOfStudy,
    required this.currentYear,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      educationLevel: json['education_level'],
      fieldOfStudy: json['field_of_study'],
      currentYear: json['current_year'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'education_level': educationLevel,
      'field_of_study': fieldOfStudy,
      'current_year': currentYear,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? avatarUrl,
    String? educationLevel,
    String? fieldOfStudy,
    String? currentYear,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      educationLevel: educationLevel ?? this.educationLevel,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      currentYear: currentYear ?? this.currentYear,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
