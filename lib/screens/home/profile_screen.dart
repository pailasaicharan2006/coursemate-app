import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/course_provider.dart';
import 'package:coursemate_app/providers/learning_provider.dart';
import 'package:coursemate_app/providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user             = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final interestsAsync   = ref.watch(userInterestsProvider);
    final skillsAsync      = ref.watch(userSkillsProvider);
    final goalsAsync       = ref.watch(userGoalsProvider);
    final savedCoursesAsync    = ref.watch(savedCoursesProvider);
    final userCoursesAsync     = ref.watch(userCoursesLearningProvider);
    final certificatesAsync    = ref.watch(certificatesProvider);

    final savedCount = savedCoursesAsync.maybeWhen(
      data: (list) => list.length, orElse: () => 0,
    );
    final inProgressCount = userCoursesAsync.maybeWhen(
      data: (list) => list
          .where((c) => c.status == 'in_progress' || c.status == 'enrolled')
          .length,
      orElse: () => 0,
    );
    final completedCount = userCoursesAsync.maybeWhen(
      data: (list) => list.where((c) => c.status == 'completed').length,
      orElse: () => 0,
    );

    final profile     = userProfileAsync.value;
    final displayName = (profile != null && profile.name.isNotEmpty)
        ? profile.name
        : (user?.email?.split('@').first ?? 'Learner');
    final email = (profile != null && profile.email.isNotEmpty)
        ? profile.email
        : (user?.email ?? '');

    String initials = 'CM';
    if (displayName.isNotEmpty) {
      final parts = displayName.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0]
            .substring(0, parts[0].length >= 2 ? 2 : 1)
            .toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(
                color: AppTheme.darkTextPrimary,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,
                color: AppTheme.darkTextSecondary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile header card ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkBorderCyan),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.cyanPrimary.withValues(alpha: 0.07),
                    AppTheme.darkCardBg,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.cyanPrimary,
                          AppTheme.cyanSecondary
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cyanPrimary.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppTheme.darkBgMain,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(displayName,
                      style: const TextStyle(
                          color: AppTheme.darkTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: const TextStyle(
                          color: AppTheme.darkTextSecondary, fontSize: 14)),
                  if (profile != null) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (profile.educationLevel.isNotEmpty)
                          _infoChip(profile.educationLevel),
                        if (profile.fieldOfStudy.isNotEmpty)
                          _infoChip(profile.fieldOfStudy),
                        if (profile.currentYear.isNotEmpty)
                          _infoChip(profile.currentYear),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Stats row ─────────────────────────────────────────────────
            Row(
              children: [
                _statCard('Saved', '$savedCount'),
                _statCard('In Progress', '$inProgressCount'),
                _statCard('Completed', '$completedCount'),
              ],
            ),
            const SizedBox(height: 24),

            // ── Interests ─────────────────────────────────────────────────
            _sectionTitle('My Interests'),
            const SizedBox(height: 10),
            interestsAsync.when(
              data: (interests) => interests.isEmpty
                  ? const Text('No interests added yet.',
                      style:
                          TextStyle(color: AppTheme.darkTextSecondary))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: interests
                          .map((e) => _cyanChip(e, AppTheme.cyanPrimary))
                          .toList(),
                    ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 22),

            // ── Skills ────────────────────────────────────────────────────
            _sectionTitle('My Skills'),
            const SizedBox(height: 10),
            skillsAsync.when(
              data: (skills) => skills.isEmpty
                  ? const Text('No skills added yet.',
                      style:
                          TextStyle(color: AppTheme.darkTextSecondary))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills
                          .map((e) => _cyanChip(e, AppTheme.cyanSecondary))
                          .toList(),
                    ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 22),

            // ── Learning Goals ────────────────────────────────────────────
            _sectionTitle('Learning Goals'),
            const SizedBox(height: 10),
            goalsAsync.when(
              data: (goals) => goals.isEmpty
                  ? const Text('No learning goals set yet.',
                      style:
                          TextStyle(color: AppTheme.darkTextSecondary))
                  : Column(
                      children: goals.map(_goalItem).toList(),
                    ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 22),

            // ── Certificates Locker ────────────────────────────────────────
            _sectionTitle('Certificates Locker'),
            const SizedBox(height: 10),
            certificatesAsync.when(
              data: (certificates) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/certificates'),
                  borderRadius: BorderRadius.circular(12),
                  hoverColor:
                      AppTheme.cyanPrimary.withValues(alpha: 0.04),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.darkBorderCyan),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.cyanSecondary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_outlined,
                            color: AppTheme.cyanSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${certificates.length} ${certificates.length == 1 ? "Certificate" : "Certificates"} Earned',
                                style: const TextStyle(
                                    color: AppTheme.darkTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'View credentials, upload files & manage links',
                                style: TextStyle(
                                    color: AppTheme.darkTextSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppTheme.darkTextSecondary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 28),

            // ── Edit Profile button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/edit-profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.cyanPrimary,
                  side: const BorderSide(
                      color: AppTheme.cyanPrimary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Edit Profile',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Log Out ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) context.go('/login');
                },
                child: const Text('Log Out',
                    style: TextStyle(
                        color: Color(0xFFEF4444), fontSize: 15)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkBorderCyan,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorderCyan),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppTheme.darkTextSecondary, fontSize: 12)),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.darkCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorderCyan),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppTheme.cyanPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.darkTextSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: AppTheme.darkTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.bold));
  }

  Widget _cyanChip(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _goalItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppTheme.cyanPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: AppTheme.darkTextPrimary))),
        ],
      ),
    );
  }
}
