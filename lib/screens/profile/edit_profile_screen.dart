import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/course_provider.dart';
import 'package:coursemate_app/providers/profile_provider.dart';
import 'package:coursemate_app/services/profile_service.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _newGoalController = TextEditingController();

  String selectedEducation = 'Undergraduate';
  String selectedYear = '3rd Year';

  List<String> interests = [];
  List<String> skills = [];
  List<String> goals = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  final List<String> _educationOptions = [
    'High School',
    'Undergraduate',
    'Postgraduate',
    'PhD',
    'Professional'
  ];

  final List<String> _yearOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    'Final Year',
    'Graduated'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        _nameController.text = profile.name;
        _bioController.text = profile.bio ?? '';
        if (_educationOptions.contains(profile.educationLevel)) {
          selectedEducation = profile.educationLevel;
        }
        if (_yearOptions.contains(profile.currentYear)) {
          selectedYear = profile.currentYear;
        }
      }
      final curInterests = ref.read(userInterestsProvider).value;
      if (curInterests != null) interests = List.from(curInterests);
      final curSkills = ref.read(userSkillsProvider).value;
      if (curSkills != null) skills = List.from(curSkills);
      final curGoals = ref.read(userGoalsProvider).value;
      if (curGoals != null) goals = List.from(curGoals);

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _newGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final profileService = ProfileService();
      final existingProfile = ref.read(userProfileProvider).value;

      if (existingProfile != null) {
        final updated = existingProfile.copyWith(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          educationLevel: selectedEducation,
          currentYear: selectedYear,
          updatedAt: DateTime.now(),
        );
        await profileService.updateProfile(updated);
      }

      await profileService.saveUserInterests(user.id, interests);
      await profileService.saveUserSkills(user.id, skills);
      await profileService.saveUserGoals(user.id, goals);

      // Invalidate all related providers to refresh recommendations and UI
      ref.invalidate(userProfileProvider);
      ref.invalidate(userInterestsProvider);
      ref.invalidate(userSkillsProvider);
      ref.invalidate(userGoalsProvider);
      ref.invalidate(recommendedCoursesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! Recommendations refreshed.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppTheme.darkBgMain;
    final textPrimary = AppTheme.darkTextPrimary;
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF63667E);
    final cardBg = AppTheme.darkCardBg;
    final accentCyan = isDark ? AppTheme.cyanSecondary : const Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: accentCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Full Name', _nameController, isDark: isDark, cardBg: cardBg, textPrimary: textPrimary, textSecondary: textSecondary),
              const SizedBox(height: 16),
              Text('Education Level', style: TextStyle(color: textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedEducation,
                dropdownColor: cardBg,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E4ED)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E4ED)),
                  ),
                ),
                items: _educationOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedEducation = val);
                },
              ),
              const SizedBox(height: 16),
              Text('Current Year', style: TextStyle(color: textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedYear,
                dropdownColor: cardBg,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E4ED)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E4ED)),
                  ),
                ),
                items: _yearOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedYear = val);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField('Bio', _bioController, maxLines: 3, isDark: isDark, cardBg: cardBg, textPrimary: textPrimary, textSecondary: textSecondary),
              const SizedBox(height: 24),
              _buildChipSection('Interests', interests, (item) {
                setState(() => interests.remove(item));
              }, () => _showAddItemDialog('Add Interest', (val) {
                    setState(() => interests.add(val));
                  }), textPrimary: textPrimary, accentCyan: accentCyan),
              const SizedBox(height: 24),
              _buildChipSection('Skills', skills, (item) {
                setState(() => skills.remove(item));
              }, () => _showAddItemDialog('Add Skill', (val) {
                    setState(() => skills.add(val));
                  }), textPrimary: textPrimary, accentCyan: accentCyan),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Learning Goals',
                    style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: accentCyan),
                    onPressed: () => _showAddItemDialog('Add Learning Goal', (val) {
                      setState(() => goals.add(val));
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...goals.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => goals.remove(g)),
                          child: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(g, style: TextStyle(color: textPrimary))),
                      ],
                    ),
                  )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyanPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E4ED)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: isDark ? BorderSide.none : const BorderSide(color: Color(0xFFE2E4ED)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipSection(
    String title,
    List<String> items,
    Function(String) onDeleted,
    VoidCallback onAdd, {
    required Color textPrimary,
    required Color accentCyan,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: Icon(Icons.add_circle, color: accentCyan), onPressed: onAdd),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((e) => InputChip(
                    label: Text(e, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: AppTheme.cyanPrimary.withAlpha(51),
                    onDeleted: () => onDeleted(e),
                    deleteIconColor: Colors.white70,
                    side: BorderSide.none,
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _showAddItemDialog(String title, Function(String) onAdd) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppTheme.darkCardBg;
    final textPrimary = AppTheme.darkTextPrimary;
    final textSecondary = isDark ? Colors.grey : const Color(0xFF63667E);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        title: Text(title, style: TextStyle(color: textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter value',
            hintStyle: TextStyle(color: textSecondary),
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text('Cancel', style: TextStyle(color: textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanPrimary),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onAdd(controller.text.trim());
                context.pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
