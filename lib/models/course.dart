class Course {
  final String id;
  final String title;
  final String provider;
  final String description;
  final String category;
  final String difficulty;
  final double durationHours;
  final double rating;
  final int reviewCount;
  final List<String> skills;
  final List<String> interests;
  final List<String> prerequisites;
  final List<String> learningOutcomes;
  final List<String> curriculum;
  final String courseUrl;
  final String imageUrl;
  final bool isFree;
  final DateTime createdAt;
  
  // Transient fields
  final double matchScore;
  final List<String> matchingInterests;
  final List<String> matchingSkills;
  final List<String> prerequisitesMet;
  final List<String> skillsToLearn;

  Course({
    required this.id,
    required this.title,
    required this.provider,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationHours,
    required this.rating,
    required this.reviewCount,
    required this.skills,
    required this.interests,
    required this.prerequisites,
    required this.learningOutcomes,
    required this.curriculum,
    required this.courseUrl,
    required this.imageUrl,
    required this.isFree,
    required this.createdAt,
    this.matchScore = 0.0,
    this.matchingInterests = const [],
    this.matchingSkills = const [],
    this.prerequisitesMet = const [],
    this.skillsToLearn = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      provider: json['provider'],
      description: json['description'],
      category: json['category'],
      difficulty: json['difficulty'],
      durationHours: (json['duration_hours'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'],
      skills: List<String>.from(json['skills'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      learningOutcomes: List<String>.from(json['learning_outcomes'] ?? []),
      curriculum: List<String>.from(json['curriculum'] ?? []),
      courseUrl: json['course_url'],
      imageUrl: json['image_url'],
      isFree: json['is_free'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'duration_hours': durationHours,
      'rating': rating,
      'review_count': reviewCount,
      'skills': skills,
      'interests': interests,
      'prerequisites': prerequisites,
      'learning_outcomes': learningOutcomes,
      'curriculum': curriculum,
      'course_url': courseUrl,
      'image_url': imageUrl,
      'is_free': isFree,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? provider,
    String? description,
    String? category,
    String? difficulty,
    double? durationHours,
    double? rating,
    int? reviewCount,
    List<String>? skills,
    List<String>? interests,
    List<String>? prerequisites,
    List<String>? learningOutcomes,
    List<String>? curriculum,
    String? courseUrl,
    String? imageUrl,
    bool? isFree,
    DateTime? createdAt,
    double? matchScore,
    List<String>? matchingInterests,
    List<String>? matchingSkills,
    List<String>? prerequisitesMet,
    List<String>? skillsToLearn,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      durationHours: durationHours ?? this.durationHours,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      prerequisites: prerequisites ?? this.prerequisites,
      learningOutcomes: learningOutcomes ?? this.learningOutcomes,
      curriculum: curriculum ?? this.curriculum,
      courseUrl: courseUrl ?? this.courseUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isFree: isFree ?? this.isFree,
      createdAt: createdAt ?? this.createdAt,
      matchScore: matchScore ?? this.matchScore,
      matchingInterests: matchingInterests ?? this.matchingInterests,
      matchingSkills: matchingSkills ?? this.matchingSkills,
      prerequisitesMet: prerequisitesMet ?? this.prerequisitesMet,
      skillsToLearn: skillsToLearn ?? this.skillsToLearn,
    );
  }
}
