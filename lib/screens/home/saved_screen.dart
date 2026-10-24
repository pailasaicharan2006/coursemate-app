import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/course_provider.dart';
import 'package:coursemate_app/widgets/course_card.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'AI & Machine Learning',
    'Data Science',
    'Web Development',
    'Mobile Development',
    'Design',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final savedCoursesAsync = ref.watch(savedCoursesProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Saved Courses',
          style: TextStyle(
            color: AppTheme.darkTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppTheme.cyanPrimary),
            tooltip: 'Ask Atom',
            onPressed: () => context.push('/ai-chat'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: AppTheme.darkTextSecondary),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.darkTextPrimary),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search saved courses...',
                hintStyle:
                    const TextStyle(color: AppTheme.darkTextHint, fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.cyanPrimary, size: 20),
                filled: true,
                fillColor: AppTheme.darkCardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.darkBorderCyan),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.darkBorderCyan),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppTheme.cyanPrimary, width: 1.5),
                ),
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.cyanPrimary.withValues(alpha: 0.15)
                            : AppTheme.darkCardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.cyanPrimary
                              : AppTheme.darkBorderCyan,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.cyanPrimary
                              : AppTheme.darkTextSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Course list
          Expanded(
            child: savedCoursesAsync.when(
              data: (savedList) {
                final query =
                    _searchController.text.trim().toLowerCase();

                final filteredSaved = savedList.where((sc) {
                  final course = sc.course;
                  if (course == null) return false;
                  final matchesQuery = query.isEmpty ||
                      course.title.toLowerCase().contains(query) ||
                      course.provider.toLowerCase().contains(query);
                  final matchesCategory = selectedFilter == 'All' ||
                      course.category
                          .toLowerCase()
                          .contains(selectedFilter.toLowerCase()) ||
                      selectedFilter
                          .toLowerCase()
                          .contains(course.category.toLowerCase());
                  return matchesQuery && matchesCategory;
                }).toList();

                if (filteredSaved.isEmpty) {
                  return _buildEmptyState(context);
                }

                return LayoutBuilder(
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

                    if (columns >= 2) {
                      return Center(
                        child: ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxWidth: 1240),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredSaved.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing:
                                  columns == 3 ? 20.0 : 16.0,
                              mainAxisSpacing:
                                  columns == 3 ? 20.0 : 16.0,
                              childAspectRatio:
                                  columns == 3 ? 0.81 : 0.84,
                            ),
                            itemBuilder: (context, index) {
                              final savedCourse =
                                  filteredSaved[index];
                              final course = savedCourse.course!;
                              return CourseCard(
                                course: course,
                                isSaved: true,
                                margin: EdgeInsets.zero,
                                onViewDetails: () => context
                                    .push('/course/${course.id}'),
                                onUnsave: () async {
                                  if (user == null) return;
                                  try {
                                    await ref
                                        .read(courseServiceProvider)
                                        .unsaveCourse(
                                            user.id, course.id);
                                    ref.invalidate(
                                        savedCoursesProvider);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            'Failed to remove: $e'),
                                      ));
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSaved.length,
                      itemBuilder: (context, index) {
                        final savedCourse = filteredSaved[index];
                        final course = savedCourse.course!;
                        return CourseCard(
                          course: course,
                          isSaved: true,
                          onViewDetails: () =>
                              context.push('/course/${course.id}'),
                          onUnsave: () async {
                            if (user == null) return;
                            try {
                              await ref
                                  .read(courseServiceProvider)
                                  .unsaveCourse(user.id, course.id);
                              ref.invalidate(savedCoursesProvider);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Failed to remove: $e'),
                                ));
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.cyanPrimary),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error loading saved courses: $err',
                  style: const TextStyle(color: AppTheme.darkTextSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_border,
              size: 72, color: AppTheme.darkTextSecondary),
          const SizedBox(height: 16),
          const Text(
            'No saved courses yet',
            style: TextStyle(
              color: AppTheme.darkTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Courses you bookmark will appear here.',
            style: TextStyle(color: AppTheme.darkTextSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home/discover'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyanPrimary,
              foregroundColor: AppTheme.darkBgMain,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Explore Courses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
