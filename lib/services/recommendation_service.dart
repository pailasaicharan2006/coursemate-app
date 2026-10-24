import 'package:coursemate_app/models/course.dart';
import 'package:coursemate_app/services/profile_service.dart';
import 'package:coursemate_app/services/course_service.dart';

class RecommendationService {
  final ProfileService _profileService = ProfileService();
  final CourseService _courseService = CourseService();

  Future<List<Course>> getRecommendations(String userId) async {
    try {
      final interests = await _profileService.getUserInterests(userId);
      final skills = await _profileService.getUserSkills(userId);
      final goals = await _profileService.getUserGoals(userId);

      final courses = await _courseService.getAllCourses();

      final scored = courses.map((course) {
        final score = calculateMatchScore(course, interests, skills, goals);
        final matchingInterests = _getIntersection(course.interests, interests);
        final matchingSkills = _getIntersection(course.skills, skills);
        final skillsToLearn = _getDifference(course.skills, skills);
        final prerequisitesMet = _getIntersection(course.prerequisites, skills);
        return course.copyWith(
          matchScore: score,
          matchingInterests: matchingInterests,
          matchingSkills: matchingSkills,
          skillsToLearn: skillsToLearn,
          prerequisitesMet: prerequisitesMet,
        );
      }).toList();

      scored.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      return scored;
    } catch (e) {
      throw Exception('Failed to generate recommendations: $e');
    }
  }

  double calculateMatchScore(
    Course course,
    List<String> userInterests,
    List<String> userSkills,
    List<String> userGoals,
  ) {
    double score = 0.0;

    // Interest overlap (40 points max) — use course.interests
    final matchedInterests = _getIntersection(course.interests, userInterests);
    score += (matchedInterests.length * 10).clamp(0, 40).toDouble();

    // Skill overlap (30 points max)
    final matchedSkills = _getIntersection(course.skills, userSkills);
    score += (matchedSkills.length * 10).clamp(0, 30).toDouble();

    // Goal alignment (20 points max)
    final matchedGoals = _calculateGoalAlignment(course, userGoals);
    score += (matchedGoals * 5).clamp(0, 20).toDouble();

    // Prerequisite met bonus (10 points max)
    final prereqsMet = _getIntersection(course.prerequisites, userSkills);
    score += (prereqsMet.length * 5).clamp(0, 10).toDouble();

    return score.clamp(0, 100);
  }

  List<String> _getIntersection(List<String> a, List<String> b) {
    final lowerB = b.map((e) => e.toLowerCase()).toSet();
    return a.where((element) => lowerB.contains(element.toLowerCase())).toList();
  }

  List<String> _getDifference(List<String> source, List<String> toExclude) {
    final lowerExclude = toExclude.map((e) => e.toLowerCase()).toSet();
    return source
        .where((element) => !lowerExclude.contains(element.toLowerCase()))
        .toList();
  }

  int _calculateGoalAlignment(Course course, List<String> goals) {
    int alignment = 0;
    final lowerGoals = goals.map((g) => g.toLowerCase()).toList();
    final lowerCategory = course.category.toLowerCase();
    final lowerSkills = course.skills.map((s) => s.toLowerCase()).toList();

    for (final goal in lowerGoals) {
      if (goal.contains('internship')) {
        if (lowerCategory.contains('data') ||
            lowerSkills.contains('python') ||
            lowerSkills.contains('sql')) {
          alignment += 2;
        } else {
          alignment += 1;
        }
      } else if (goal.contains('placement')) {
        alignment += 1;
      } else if (goal.contains('project')) {
        if (lowerCategory.contains('web') ||
            lowerCategory.contains('mobile') ||
            lowerSkills.contains('python')) {
          alignment += 2;
        } else {
          alignment += 1;
        }
      } else if (goal.contains('interview')) {
        alignment += 1;
      } else if (goal.contains('skill')) {
        alignment += 1;
      } else if (goal.contains('career')) {
        alignment += 1;
      }
    }
    return alignment;
  }
}
