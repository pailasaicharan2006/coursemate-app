import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/services/profile_service.dart';

class SkillSelectionScreen extends ConsumerStatefulWidget {
  const SkillSelectionScreen({super.key});

  @override
  ConsumerState<SkillSelectionScreen> createState() => _SkillSelectionScreenState();
}

class _SkillSelectionScreenState extends ConsumerState<SkillSelectionScreen> {
  final Set<String> _selectedSkills = {};
  bool _isLoading = false;

  final Color _bgColor = const Color(0xFF12121F);
  final Color _cardColor = const Color(0xFF1A1A2E);
  final Color _accentPurple = const Color(0xFF6C63FF);

  final List<Map<String, String>> _skills = [
    {'name': 'Python', 'icon': '🐍'},
    {'name': 'Java', 'icon': '☕'},
    {'name': 'SQL', 'icon': '🗃️'},
    {'name': 'Statistics', 'icon': '📊'},
    {'name': 'JavaScript', 'icon': '🌐'},
    {'name': 'Dart/Flutter', 'icon': '📱'},
    {'name': 'Git', 'icon': '🔀'},
    {'name': 'Data Analysis', 'icon': '📈'},
    {'name': 'Machine Learning', 'icon': '🧠'},
    {'name': 'UI/UX Design', 'icon': '🎨'},
  ];

  Future<void> _saveSkills() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileService = ProfileService();
        await profileService.saveUserSkills(user.id, _selectedSkills.toList());
      }
      if (mounted) context.push('/onboarding/goals');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving skills: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Skill Selection', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => context.push('/ai-chat'),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Colors.white),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '3 of 4',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: 0.75,
              backgroundColor: _cardColor,
              valueColor: AlwaysStoppedAnimation<Color>(_accentPurple),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What skills do you already have?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Help us understand your current level',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12,
                      runSpacing: 16,
                      children: _skills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill['name']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSkills.remove(skill['name']);
                              } else {
                                _selectedSkills.add(skill['name']!);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? _accentPurple : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? _accentPurple : Colors.white24,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  skill['icon']!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  skill['name']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveSkills,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
