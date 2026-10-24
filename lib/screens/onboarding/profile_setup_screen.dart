import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final _yearController = TextEditingController();
  final _bioController = TextEditingController();
  
  String? _educationLevel;
  bool _isLoading = false;

  final Color _bgColor = const Color(0xFF12121F);
  final Color _inputColor = const Color(0xFF252545);
  final Color _accentPurple = const Color(0xFF6C63FF);
  
  final List<String> _educationLevels = [
    'High School',
    'Undergraduate',
    'Postgraduate',
    'PhD',
    'Professional'
  ];

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.userMetadata != null) {
      _nameController.text = user.userMetadata!['full_name'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || _educationLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill the required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'user_id': user.id,
          'name': _nameController.text.trim(),
          'email': user.email ?? '',
          'education_level': _educationLevel,
          'field_of_study': _fieldOfStudyController.text.trim(),
          'current_year': _yearController.text.trim(),
          'bio': _bioController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }
      if (mounted) context.push('/onboarding/interests');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
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
        title: const Text('Set Up Your Profile', style: TextStyle(color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '1 of 4',
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
              value: 0.25,
              backgroundColor: _inputColor,
              valueColor: AlwaysStoppedAnimation<Color>(_accentPurple),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Full Name *',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _educationLevel,
                      dropdownColor: _inputColor,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Education Level *',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: _inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _educationLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _educationLevel = val),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _fieldOfStudyController,
                      hint: 'Field of Study (e.g. Computer Science)',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _yearController,
                      hint: 'Current Year (e.g. 3rd Year)',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bioController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Bio (optional)',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: _inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: _inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
