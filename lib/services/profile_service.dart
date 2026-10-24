import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/models/user_profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<UserProfile> createProfile(UserProfile profile) async {
    try {
      final response = await _supabase
          .from('profiles')
          .insert(profile.toJson())
          .select()
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<List<String>> getUserInterests(String userId) async {
    try {
      final response = await _supabase
          .from('user_interests')
          .select('interest')
          .eq('user_id', userId);
      return (response as List).map((e) => e['interest'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch user interests: $e');
    }
  }

  Future<void> saveUserInterests(String userId, List<String> interests) async {
    try {
      await _supabase.from('user_interests').delete().eq('user_id', userId);
      if (interests.isNotEmpty) {
        final data = interests.map((i) => {'user_id': userId, 'interest': i}).toList();
        await _supabase.from('user_interests').insert(data);
      }
    } catch (e) {
      throw Exception('Failed to save user interests: $e');
    }
  }

  Future<List<String>> getUserSkills(String userId) async {
    try {
      final response = await _supabase
          .from('user_skills')
          .select('skill')
          .eq('user_id', userId);
      return (response as List).map((e) => e['skill'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch user skills: $e');
    }
  }

  Future<void> saveUserSkills(String userId, List<String> skills) async {
    try {
      await _supabase.from('user_skills').delete().eq('user_id', userId);
      if (skills.isNotEmpty) {
        final data = skills.map((s) => {'user_id': userId, 'skill': s}).toList();
        await _supabase.from('user_skills').insert(data);
      }
    } catch (e) {
      throw Exception('Failed to save user skills: $e');
    }
  }

  Future<List<String>> getUserGoals(String userId) async {
    try {
      final response = await _supabase
          .from('learning_goals')
          .select('goal')
          .eq('user_id', userId);
      return (response as List).map((e) => e['goal'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch user goals: $e');
    }
  }

  Future<void> saveUserGoals(String userId, List<String> goals) async {
    try {
      await _supabase.from('learning_goals').delete().eq('user_id', userId);
      if (goals.isNotEmpty) {
        final data = goals.map((g) => {'user_id': userId, 'goal': g}).toList();
        await _supabase.from('learning_goals').insert(data);
      }
    } catch (e) {
      throw Exception('Failed to save user goals: $e');
    }
  }

  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return false;
      // Check if profile has name and at least one interest set
      final interests = await getUserInterests(userId);
      return profile.name.isNotEmpty && interests.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check onboarding status: $e');
    }
  }
}
