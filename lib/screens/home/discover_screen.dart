import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/models/course.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/course_provider.dart';
import 'package:coursemate_app/providers/notification_provider.dart';
import 'package:coursemate_app/providers/profile_provider.dart';
import 'package:coursemate_app/widgets/course_card.dart';

// ---------------------------------------------------------------------------
// Discover-page design tokens (black / cyan glassmorphism)
// These are local to this screen and do NOT affect the global theme.
// ---------------------------------------------------------------------------
class _DC {
  static const bgMain      = Color(0xFF050A0D);
  static const bgSecondary = Color(0xFF071318);
  static const cardBg      = Color(0xFF0B171D);
  static const glassSurface= Color(0xFF0D1E27);
  static const cyanPrimary = Color(0xFF20DDF5);
  static const cyanSecondary = Color(0xFF168FE5);
  static const textMain    = Color(0xFFF4F7FA);
  static const textSub     = Color(0xFF9BAAB7);
  static const borderCyan  = Color(0x2820DDF5); // low-opacity cyan border
  static const borderCyanMid = Color(0x5020DDF5);
}

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String selectedFilter = 'All';
  String selectedSort = 'Best Match';

  final List<String> filters = [
    'All',
    'AI & Machine Learning',
    'Data Science',
    'Web Development',
    'Mobile Development',
    'Design',
    'Computer Science',
    'Cloud Computing',
  ];
  final List<String> sortOptions = ['Best Match', 'Highest Rated', 'Duration'];

  Future<void> _refresh() async {
    ref.invalidate(recommendedCoursesProvider);
    ref.invalidate(allCoursesProvider);
    ref.invalidate(savedCoursesProvider);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _initials(AsyncValue<dynamic> profileAsync, dynamic user) {
    if (profileAsync.value != null && profileAsync.value!.name.isNotEmpty) {
      final parts = (profileAsync.value!.name as String).trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      final s = parts[0];
      return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    }
    if (user?.email != null && (user!.email as String).isNotEmpty) {
      return (user.email as String).substring(0, 2).toUpperCase();
    }
    return 'CM';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user             = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final unreadCount      = ref.watch(unreadCountProvider);
    final savedCoursesAsync= ref.watch(savedCoursesProvider);
    final recommendedAsync = ref.watch(recommendedCoursesProvider);
    final allCoursesAsync  = ref.watch(allCoursesProvider);

    final initials = _initials(userProfileAsync, user);

    final savedCourseIds = savedCoursesAsync.maybeWhen(
      data: (saved) => saved.map((s) => s.courseId).toSet(),
      orElse: () => <String>{},
    );

    return Scaffold(
      backgroundColor: _DC.bgMain,
      appBar: _buildAppBar(context, initials, unreadCount),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final int columns;
          if (width >= 1000) {
            columns = 3;
          } else if (width >= 650) {
            columns = 2;
          } else {
            columns = 1;
          }
          final horizontalPadding =
              width >= 1000 ? 32.0 : (width >= 650 ? 24.0 : 16.0);

          return RefreshIndicator(
            onRefresh: _refresh,
            color: _DC.cyanPrimary,
            backgroundColor: _DC.cardBg,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Hero glass panel ────────────────────────────
                        _buildHeroPanel(),
                        const SizedBox(height: 20),

                        // ── Search bar ──────────────────────────────────
                        _buildSearchBar(context),
                        const SizedBox(height: 16),

                        // ── Filter chips ────────────────────────────────
                        _buildFilterRow(),
                        const SizedBox(height: 20),

                        // ── Title + sort ────────────────────────────────
                        _buildTitleRow(),
                        const SizedBox(height: 16),

                        // ── Course grid / list ──────────────────────────
                        recommendedAsync.when(
                          data: (rec) => _buildCourseGrid(
                            context,
                            rec,
                            allCoursesAsync,
                            savedCourseIds,
                            user,
                            columns,
                          ),
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48.0),
                              child: CircularProgressIndicator(
                                  color: _DC.cyanPrimary),
                            ),
                          ),
                          error: (err, _) => _buildErrorState(err),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String initials, int unreadCount) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: _DC.bgMain.withValues(alpha: 0.88),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Logo text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Course',
                              style: TextStyle(
                                color: _DC.textMain,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Mate',
                              style: TextStyle(
                                color: _DC.cyanPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Atom / AI chat
                    IconButton(
                      icon:
                          const Icon(Icons.auto_awesome, color: _DC.cyanPrimary),
                      tooltip: 'Ask Atom',
                      onPressed: () => context.push('/ai-chat'),
                    ),
                    // Notification bell
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none,
                              color: _DC.textSub),
                          tooltip: 'Notifications',
                          onPressed: () => context.push('/notifications'),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: _DC.cyanPrimary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 14, minHeight: 14),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Color(0xFF050A0D),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Avatar
                    GestureDetector(
                      onTap: () => context.go('/home/profile'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: _DC.cyanSecondary.withValues(alpha: 0.22),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: _DC.cyanPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero panel ─────────────────────────────────────────────────────────────

  Widget _buildHeroPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: _DC.glassSurface.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _DC.borderCyan),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _DC.cyanPrimary.withValues(alpha: 0.06),
                _DC.bgSecondary.withValues(alpha: 0.90),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _DC.cyanPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _DC.borderCyanMid),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: _DC.cyanPrimary, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Personalized for you',
                          style: TextStyle(
                            color: _DC.cyanPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Discover Courses',
                style: TextStyle(
                  color: _DC.textMain,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Explore recommendations tailored to your interests, skills, and goals.',
                style: TextStyle(
                  color: _DC.textSub,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _DC.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _DC.borderCyan),
          boxShadow: [
            BoxShadow(
              color: _DC.cyanPrimary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: _DC.cyanPrimary, size: 20),
            SizedBox(width: 12),
            Text(
              'Search courses, skills, or topics...',
              style: TextStyle(color: _DC.textSub, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _DC.cyanPrimary.withValues(alpha: 0.15)
                      : _DC.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _DC.cyanPrimary : _DC.borderCyan,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? _DC.cyanPrimary : _DC.textSub,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Title + sort row ───────────────────────────────────────────────────────

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Recommendations',
          style: TextStyle(
            color: _DC.textMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _DC.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _DC.borderCyan),
          ),
          child: DropdownButton<String>(
            value: selectedSort,
            dropdownColor: _DC.cardBg,
            style: const TextStyle(
              color: _DC.cyanPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: _DC.cyanPrimary),
            isDense: true,
            items: sortOptions.map((sort) {
              return DropdownMenuItem(
                value: sort,
                child: Text(sort,
                    style: const TextStyle(color: _DC.cyanPrimary)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => selectedSort = val);
            },
          ),
        ),
      ],
    );
  }

  // ── Course grid ────────────────────────────────────────────────────────────

  Widget _buildCourseGrid(
    BuildContext context,
    List<Course> recommendedList,
    AsyncValue<List<Course>> allCoursesAsync,
    Set<String> savedCourseIds,
    dynamic user,
    int columns,
  ) {
    List<Course> coursesToShow = recommendedList;

    // Fallback to allCourses if recommendations is empty
    if (coursesToShow.isEmpty && allCoursesAsync.value != null) {
      coursesToShow = allCoursesAsync.value!;
    }

    // Apply category filter
    if (selectedFilter != 'All') {
      coursesToShow = coursesToShow.where((c) {
        return c.category.toLowerCase().contains(selectedFilter.toLowerCase()) ||
            selectedFilter.toLowerCase().contains(c.category.toLowerCase());
      }).toList();
    }

    // Apply sort
    if (selectedSort == 'Highest Rated') {
      coursesToShow = [...coursesToShow]
        ..sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSort == 'Duration') {
      coursesToShow = [...coursesToShow]
        ..sort((a, b) => a.durationHours.compareTo(b.durationHours));
    } else {
      coursesToShow = [...coursesToShow]
        ..sort((a, b) => b.matchScore.compareTo(a.matchScore));
    }

    if (coursesToShow.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, color: _DC.textSub, size: 48),
              SizedBox(height: 12),
              Text(
                'No courses found for this category.',
                style: TextStyle(color: _DC.textSub, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Build helpers for save/unsave callbacks
    VoidCallback onSave(Course course) => () async {
          if (user == null) return;
          try {
            await ref.read(courseServiceProvider).saveCourse(user.id, course.id);
            ref.invalidate(savedCoursesProvider);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save course: $e')),
              );
            }
          }
        };

    VoidCallback onUnsave(Course course) => () async {
          if (user == null) return;
          try {
            await ref.read(courseServiceProvider).unsaveCourse(user.id, course.id);
            ref.invalidate(savedCoursesProvider);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to remove bookmark: $e')),
              );
            }
          }
        };

    if (columns >= 2) {
      final crossSpacing = columns == 3 ? 20.0 : 16.0;
      final mainSpacing  = columns == 3 ? 20.0 : 16.0;
      final childAspect  = columns == 3 ? 0.81 : 0.84;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: coursesToShow.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: crossSpacing,
          mainAxisSpacing: mainSpacing,
          childAspectRatio: childAspect,
        ),
        itemBuilder: (context, index) {
          final course  = coursesToShow[index];
          final isSaved = savedCourseIds.contains(course.id);
          return CourseCard(
            course: course,
            isSaved: isSaved,
            margin: EdgeInsets.zero,
            cyanStyle: true,
            onViewDetails: () => context.push('/course/${course.id}'),
            onSave: onSave(course),
            onUnsave: onUnsave(course),
          );
        },
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: coursesToShow.length,
      itemBuilder: (context, index) {
        final course  = coursesToShow[index];
        final isSaved = savedCourseIds.contains(course.id);
        return CourseCard(
          course: course,
          isSaved: isSaved,
          cyanStyle: true,
          onViewDetails: () => context.push('/course/${course.id}'),
          onSave: onSave(course),
          onUnsave: onUnsave(course),
        );
      },
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFFF5252), size: 40),
            const SizedBox(height: 12),
            Text(
              'Failed to load recommendations: $err',
              style: const TextStyle(color: _DC.textSub),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DC.cyanSecondary,
                foregroundColor: _DC.textMain,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
