import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/profile_provider.dart';
import 'package:coursemate_app/providers/theme_provider.dart';
import 'package:coursemate_app/core/widgets/coursemate_logo.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;

    final name = (profile != null && profile.name.isNotEmpty)
        ? profile.name
        : (user?.email?.split('@').first ?? 'Learner');
    final email = user?.email ?? (profile?.email ?? '');

    final onSurfaceColor = AppTheme.darkTextPrimary;

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: onSurfaceColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurfaceColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(context, name, email, isDark),
          const SizedBox(height: 24),
          _buildSectionHeader('ACCOUNT'),
          _buildSettingRow(
            context: context,
            icon: Icons.person_outline,
            color: AppTheme.cyanPrimary,
            title: 'Edit Profile',
            subtitle: 'Update your personal details',
            onTap: () => context.push('/edit-profile'),
            isDark: isDark,
          ),
          _buildSettingRow(
            context: context,
            icon: Icons.lock_outline,
            color: AppTheme.cyanPrimary,
            title: 'Change Password',
            subtitle: 'Update your security credentials',
            onTap: () => _showChangePasswordDialog(context, isDark),
            isDark: isDark,
          ),
          _buildSettingRow(
            context: context,
            icon: Icons.notifications_none,
            color: AppTheme.cyanPrimary,
            title: 'Notifications',
            subtitle: 'Manage your alert preferences',
            onTap: () => context.push('/notifications'),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('PREFERENCES'),
          _buildSettingRow(
            context: context,
            icon: Icons.palette_outlined,
            color: AppTheme.cyanSecondary,
            title: 'Appearance',
            subtitle: isDark ? 'Dark Mode' : 'Light Mode',
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                ref.read(themeNotifierProvider.notifier).toggleTheme(val);
              },
              activeThumbColor: AppTheme.cyanPrimary,
            ),
            onTap: () {
              ref.read(themeNotifierProvider.notifier).toggleTheme(!isDark);
            },
            isDark: isDark,
          ),
          _buildSettingRow(
            context: context,
            icon: Icons.privacy_tip_outlined,
            color: AppTheme.cyanSecondary,
            title: 'Privacy',
            subtitle: 'Manage your data settings',
            onTap: () => _showPrivacyDialog(context, isDark),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('SUPPORT'),
          _buildSettingRow(
            context: context,
            icon: Icons.help_outline,
            color: Colors.green,
            title: 'Help & Support',
            subtitle: 'Get assistance and view FAQs',
            onTap: () => _showInfoDialog(context, 'Help & Support', 'For questions or support, contact support@coursemate.app', isDark),
            isDark: isDark,
          ),
          _buildSettingRow(
            context: context,
            icon: Icons.info_outline,
            color: Colors.green,
            title: 'About CourseMate',
            subtitle: 'Version 2.0.0',
            onTap: () => _showAboutDialog(context, isDark),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('DANGER ZONE'),
          _buildSettingRow(
            context: context,
            icon: Icons.logout,
            color: Colors.red,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            titleColor: Colors.red,
            onTap: () => _showLogoutConfirmDialog(context, isDark),
            isDark: isDark,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, String email, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? (isDark ? AppTheme.darkCardBg : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorderCyan,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.cyanPrimary,
            child: Icon(Icons.person, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppTheme.darkTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: AppTheme.darkTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    Color? titleColor,
    Widget? trailing,
  }) {
    final effectiveTitleColor = titleColor ?? (AppTheme.darkTextPrimary);
    final subtitleColor = AppTheme.darkTextSecondary;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(color: effectiveTitleColor, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  void _showChangePasswordDialog(BuildContext context, bool isDark) {
    final passController = TextEditingController();
    final dialogBg = AppTheme.darkCardBg;
    final textColor = AppTheme.darkTextPrimary;
    final inputFill = isDark ? AppTheme.darkBgMain : AppTheme.darkInputBg;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Change Password', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: passController,
          obscureText: true,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'New Password',
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: inputFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyanPrimary),
            onPressed: () async {
              if (passController.text.trim().length >= 6) {
                try {
                  await Supabase.instance.client.auth.updateUser(
                    UserAttributes(password: passController.text.trim()),
                  );
                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    final dialogBg = AppTheme.darkCardBg;
    final textColor = AppTheme.darkTextPrimary;
    final subColor = AppTheme.darkTextSecondary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Center(
          child: CourseMateLogo(height: 36),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              'Version 2.0.0',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Personalized Course Recommendations & AI Learning Assistant.\nPowered by Flutter & Supabase.',
              style: TextStyle(color: subColor, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close', style: TextStyle(color: AppTheme.cyanPrimary)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, bool isDark) {
    _showInfoDialog(context, 'Privacy', 'CourseMate stores your learning preferences and progress securely on Supabase.', isDark);
  }

  void _showInfoDialog(BuildContext context, String title, String content, bool isDark) {
    final dialogBg = AppTheme.darkCardBg;
    final textColor = AppTheme.darkTextPrimary;
    final subColor = AppTheme.darkTextSecondary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Text(content, style: TextStyle(color: subColor)),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Close', style: TextStyle(color: AppTheme.cyanPrimary))),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, bool isDark) {
    final dialogBg = AppTheme.darkCardBg;
    final textColor = AppTheme.darkTextPrimary;
    final subColor = AppTheme.darkTextSecondary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text('Logout', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to log out?', style: TextStyle(color: subColor)),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.pop();
                context.go('/login');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
