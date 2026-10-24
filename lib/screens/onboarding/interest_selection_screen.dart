import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/services/profile_service.dart';

class InterestSelectionScreen extends ConsumerStatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  ConsumerState<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends ConsumerState<InterestSelectionScreen> {
  final Set<String> _selectedInterests = {};
  bool _isLoading = false;

  final Color _bgColor = const Color(0xFF12121F);
  final Color _cardColor = const Color(0xFF1A1A2E);
  final Color _accentPurple = const Color(0xFF6C63FF);

  final List<Map<String, String>> _interests = [
    {'name': 'Data Science', 'icon': '📊'},
    {'name': 'AI', 'icon': '🤖'},
    {'name': 'Machine Learning', 'icon': '🧠'},
    {'name': 'Data Analytics', 'icon': '📈'},
    {'name': 'Web Development', 'icon': '🌐'},
    {'name': 'Mobile Development', 'icon': '📱'},
    {'name': 'Cybersecurity', 'icon': '🔒'},
    {'name': 'Cloud Computing', 'icon': '☁️'},
    {'name': 'UI/UX Design', 'icon': '🎨'},
    {'name': 'Programming', 'icon': '💻'},
  ];

  Future<void> _saveInterests() async {
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one interest')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileService = ProfileService();
        await profileService.saveUserInterests(user.id, _selectedInterests.toList());
      }
      if (mounted) context.push('/onboarding/skills');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving interests: $e')),
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
        title: const Text('Interest Selection', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => context.push('/ai-chat'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '2 of 4',
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
              value: 0.5,
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
                      'What are you interested in?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select all that apply to get personalized recommendations',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12,
                      runSpacing: 16,
                      children: _interests.map((interest) {
                        final isSelected = _selectedInterests.contains(interest['name']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedInterests.remove(interest['name']);
                              } else {
                                _selectedInterests.add(interest['name']!);
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
                                  interest['icon']!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  interest['name']!,
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
                        onPressed: _isLoading ? null : _saveInterests,
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
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/onboarding/skills'),
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(color: Colors.white54),
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
