import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/services/profile_service.dart';

class LearningGoalsScreen extends ConsumerStatefulWidget {
  const LearningGoalsScreen({super.key});

  @override
  ConsumerState<LearningGoalsScreen> createState() => _LearningGoalsScreenState();
}

class _LearningGoalsScreenState extends ConsumerState<LearningGoalsScreen> {
  final Set<String> _selectedGoals = {};
  bool _isLoading = false;

  final Color _bgColor = const Color(0xFF12121F);
  final Color _cardColor = const Color(0xFF1A1A2E);
  final Color _accentPurple = const Color(0xFF6C63FF);

  final List<Map<String, String>> _goals = [
    {'name': 'Get an internship', 'icon': '💼', 'desc': 'Find opportunities to gain experience'},
    {'name': 'Prepare for placements', 'icon': '🎯', 'desc': 'Get ready for campus hiring'},
    {'name': 'Learn a new skill', 'icon': '📚', 'desc': 'Expand your knowledge base'},
    {'name': 'Build projects', 'icon': '🔨', 'desc': 'Create portfolio-worthy applications'},
    {'name': 'Prepare for interviews', 'icon': '🗣️', 'desc': 'Practice and crack tech interviews'},
    {'name': 'Improve existing skills', 'icon': '⬆️', 'desc': 'Master what you already know'},
    {'name': 'Explore a career', 'icon': '🔭', 'desc': 'Discover different career paths'},
  ];

  Future<void> _saveGoalsAndFinish() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileService = ProfileService();
        await profileService.saveUserGoals(user.id, _selectedGoals.toList());
      }
      if (mounted) context.go('/home/discover'); // Triggers recommendation engine logically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving goals: $e')),
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
        title: const Text('Learning Goals', style: TextStyle(color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '4 of 4',
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
              value: 1.0,
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
                      'What are your learning goals?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select all that apply',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ..._goals.map((goal) {
                      final isSelected = _selectedGoals.contains(goal['name']);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedGoals.remove(goal['name']);
                              } else {
                                _selectedGoals.add(goal['name']!);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? _accentPurple : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  goal['icon']!,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal['name']!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? _accentPurple : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        goal['desc']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: _accentPurple)
                                else
                                  const Icon(Icons.circle_outlined, color: Colors.white24),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveGoalsAndFinish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Get Recommendations',
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
