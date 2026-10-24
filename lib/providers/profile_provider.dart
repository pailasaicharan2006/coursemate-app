import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coursemate_app/models/user_profile.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.read(profileServiceProvider).getProfile(user.id);
});

final hasProfileProvider = Provider<bool?>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => profile != null,
    loading: () => null,
    error: (_, __) => false,
  );
});

final userInterestsProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(profileServiceProvider).getUserInterests(user.id);
});

final userSkillsProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(profileServiceProvider).getUserSkills(user.id);
});

final userGoalsProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(profileServiceProvider).getUserGoals(user.id);
});
