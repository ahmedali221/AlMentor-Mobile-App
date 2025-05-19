import 'package:flutter/material.dart';

enum SearchItemType { course, program, instructor }

class AlmentorSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> programs;
  final List<Map<String, dynamic>> instructors;
  final bool isDark;
  final String locale;

  AlmentorSearchDelegate({
    required this.courses,
    required this.programs,
    required this.instructors,
    required this.isDark,
    required this.locale,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle:
            TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Start typing to search',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }

    final lowercaseQuery = query.toLowerCase();

    final filteredCourses = courses.where((course) {
      final title = course['title']?[locale]?.toString().toLowerCase() ?? '';
      final description =
          course['description']?[locale]?.toString().toLowerCase() ?? '';
      return title.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();

    final filteredPrograms = programs.where((program) {
      final title = program['title']?[locale]?.toString().toLowerCase() ?? '';
      final description =
          program['description']?[locale]?.toString().toLowerCase() ?? '';
      return title.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();

    final filteredInstructors = instructors.where((instructor) {
      final firstName = instructor['profile']?['firstName']?[locale]
              ?.toString()
              .toLowerCase() ??
          '';
      final lastName = instructor['profile']?['lastName']?[locale]
              ?.toString()
              .toLowerCase() ??
          '';
      final fullName = '$firstName $lastName';
      return fullName.contains(lowercaseQuery);
    }).toList();

    return CustomScrollView(
      slivers: [
        if (filteredCourses.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildSection('Courses', filteredCourses, Icons.book),
          ),
        if (filteredPrograms.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildSection(
                'Programs', filteredPrograms, Icons.library_books),
          ),
        if (filteredInstructors.isNotEmpty)
          SliverToBoxAdapter(
            child:
                _buildSection('Instructors', filteredInstructors, Icons.person),
          ),
        if (filteredCourses.isEmpty &&
            filteredPrograms.isEmpty &&
            filteredInstructors.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'No results found',
                style:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSection(
      String title, List<Map<String, dynamic>> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: isDark ? Colors.white70 : Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(
                item['title']?[locale]?.toString() ??
                    '${item['profile']?['firstName']?[locale]} ${item['profile']?['lastName']?[locale]}',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              subtitle: Text(
                item['description']?[locale]?.toString() ??
                    item['professionalTitle']?[locale]?.toString() ??
                    '',
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600]),
              ),
              onTap: () {
                final itemType = _getItemType(title);
                _handleNavigation(context, item, itemType);
              },
            );
          },
        ),
        const Divider(),
      ],
    );
  }

  SearchItemType _getItemType(String title) {
    switch (title.toLowerCase()) {
      case 'courses':
        return SearchItemType.course;
      case 'programs':
        return SearchItemType.program;
      case 'instructors':
        return SearchItemType.instructor;
      default:
        throw ArgumentError('Invalid section title');
    }
  }

  void _handleNavigation(
      BuildContext context, Map<String, dynamic> item, SearchItemType type) {
    // Close search first
    close(context, '');

    // Delay navigation slightly to ensure smooth transition
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (type) {
        case SearchItemType.course:
          Navigator.pushNamed(
            context,
            '/course_details',
            arguments: {
              'courseId': item['_id'],
              'course': item,
            },
          );
          break;

        case SearchItemType.program:
          Navigator.pushNamed(
            context,
            '/program_details',
            arguments: {
              'programId': item['_id'],
              'program': item,
            },
          );
          break;

        case SearchItemType.instructor:
          Navigator.pushNamed(
            context,
            '/instructor_details',
            arguments: {
              'instructor': item,
              'isArabic': locale == 'ar',
            },
          );
          break;
      }
    });
  }
}
