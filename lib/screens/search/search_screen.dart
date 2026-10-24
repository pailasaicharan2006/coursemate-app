import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coursemate_app/models/course.dart';
import 'package:coursemate_app/providers/auth_provider.dart';
import 'package:coursemate_app/providers/course_provider.dart';
import 'package:coursemate_app/widgets/course_card.dart';
import 'package:coursemate_app/core/theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool showFilters = false;

  // Filter States
  String selectedDifficulty = 'Any';
  String selectedRating = 'Any';
  String selectedSort = 'Best Match';

  List<Course> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final courseService = ref.read(courseServiceProvider);
      List<Course> results;
      if (query.trim().isEmpty) {
        results = await courseService.getAllCourses();
      } else {
        results = await courseService.searchCourses(query.trim());
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final savedCoursesAsync = ref.watch(savedCoursesProvider);
    final savedCourseIds = savedCoursesAsync.maybeWhen(
      data: (saved) => saved.map((s) => s.courseId).toSet(),
      orElse: () => <String>{},
    );

    // Filter results locally
    List<Course> displayResults = _searchResults.where((c) {
      if (selectedDifficulty != 'Any' &&
          c.difficulty.toLowerCase() != selectedDifficulty.toLowerCase()) {
        return false;
      }
      if (selectedRating != 'Any') {
        final minRating = double.tryParse(selectedRating.replaceAll('+', '')) ?? 0.0;
        if (c.rating < minRating) return false;
      }
      return true;
    }).toList();

    // Sort results
    if (selectedSort == 'Highest Rated') {
      displayResults.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedSort == 'Shortest') {
      displayResults.sort((a, b) => a.durationHours.compareTo(b.durationHours));
    } else if (selectedSort == 'Longest') {
      displayResults.sort((a, b) => b.durationHours.compareTo(a.durationHours));
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBgMain,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBgMain,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.darkTextPrimary),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            style: TextStyle(color: AppTheme.darkTextPrimary),
            onChanged: (text) => _performSearch(text),
            decoration: InputDecoration(
              hintText: 'Search courses, skills, topics...',
              hintStyle: TextStyle(color: AppTheme.darkTextHint),
              filled: true,
              fillColor: AppTheme.darkCardBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: showFilters ? AppTheme.cyanPrimary : AppTheme.cyanSecondary,
                ),
                onPressed: () => setState(() => showFilters = !showFilters),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (showFilters) _buildFilters(isDark),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.cyanPrimary),
                  )
                : displayResults.isEmpty
                    ? Center(
                        child: Text(
                          'No courses found.',
                          style: TextStyle(color: AppTheme.darkTextSecondary),
                        ),
                      )
                    : LayoutBuilder(
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
                                constraints: const BoxConstraints(maxWidth: 1240),
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: displayResults.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: columns == 3 ? 20.0 : 16.0,
                                    mainAxisSpacing: columns == 3 ? 20.0 : 16.0,
                                    childAspectRatio: columns == 3 ? 0.81 : 0.84,
                                  ),
                                  itemBuilder: (context, index) {
                                    final course = displayResults[index];
                                    final isSaved = savedCourseIds.contains(course.id);

                                    return CourseCard(
                                      course: course,
                                      isSaved: isSaved,
                                      margin: EdgeInsets.zero,
                                      onViewDetails: () => context.push('/course/${course.id}'),
                                      onSave: () async {
                                        if (user == null) return;
                                        try {
                                          await ref.read(courseServiceProvider).saveCourse(user.id, course.id);
                                          ref.invalidate(savedCoursesProvider);
                                        } catch (_) {}
                                      },
                                      onUnsave: () async {
                                        if (user == null) return;
                                        try {
                                          await ref.read(courseServiceProvider).unsaveCourse(user.id, course.id);
                                          ref.invalidate(savedCoursesProvider);
                                        } catch (_) {}
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayResults.length,
                            itemBuilder: (context, index) {
                              final course = displayResults[index];
                              final isSaved = savedCourseIds.contains(course.id);

                              return CourseCard(
                                course: course,
                                isSaved: isSaved,
                                onViewDetails: () => context.push('/course/${course.id}'),
                                onSave: () async {
                                  if (user == null) return;
                                  try {
                                    await ref.read(courseServiceProvider).saveCourse(user.id, course.id);
                                    ref.invalidate(savedCoursesProvider);
                                  } catch (_) {}
                                },
                                onUnsave: () async {
                                  if (user == null) return;
                                  try {
                                    await ref.read(courseServiceProvider).unsaveCourse(user.id, course.id);
                                    ref.invalidate(savedCoursesProvider);
                                  } catch (_) {}
                                },
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    final cardBg = AppTheme.darkCardBg;
    final textPrimary = AppTheme.darkTextPrimary;
    final textSecondary = AppTheme.darkTextSecondary;
    final chipUnselectedBg = AppTheme.darkBgMain;

    return Container(
      color: cardBg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Difficulty', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Any', 'Beginner', 'Intermediate', 'Advanced'].map((e) => ChoiceChip(
                  label: Text(e),
                  selected: selectedDifficulty == e,
                  onSelected: (val) {
                    if (val) setState(() => selectedDifficulty = e);
                  },
                  backgroundColor: chipUnselectedBg,
                  selectedColor: AppTheme.cyanPrimary.withValues(alpha: 0.30),
                  labelStyle: TextStyle(color: selectedDifficulty == e ? AppTheme.darkBgMain : AppTheme.darkTextSecondary),
                )).toList(),
          ),
          const SizedBox(height: 16),
          Text('Rating', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Any', '4.5+', '4.0+', '3.0+'].map((e) => ChoiceChip(
                  label: Text(e),
                  selected: selectedRating == e,
                  onSelected: (val) {
                    if (val) setState(() => selectedRating = e);
                  },
                  backgroundColor: chipUnselectedBg,
                  selectedColor: AppTheme.cyanPrimary.withValues(alpha: 0.30),
                  labelStyle: TextStyle(color: selectedRating == e ? AppTheme.darkBgMain : AppTheme.darkTextSecondary),
                )).toList(),
          ),
          const SizedBox(height: 16),
          Text('Sort By', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedSort,
            dropdownColor: cardBg,
            isExpanded: true,
            style: TextStyle(color: textPrimary),
            underline: Container(height: 1, color: textSecondary),
            items: ['Best Match', 'Highest Rated', 'Shortest', 'Longest']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => selectedSort = val);
            },
          ),
        ],
      ),
    );
  }
}
