import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Core/Constants/apiConstants.dart';

class CategoryCourses extends StatefulWidget {
  final String categoryId;

  const CategoryCourses({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryCourses> createState() => _CategoryCoursesState();
}

class _CategoryCoursesState extends State<CategoryCourses> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCategoryCourses();
  }

  Future<void> fetchCategoryCourses() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.7:5000/api/courses/category/${widget.categoryId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data[0]);
        if (data is List) {
          setState(() {
            courses = data.cast<Map<String, dynamic>>().toList();
            isLoading = false;
          });
        } else if (data['success'] == true && data['data'] is List) {
          setState(() {
            courses =
                (data['data'] as List).cast<Map<String, dynamic>>().toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Invalid data format from server.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load courses: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching courses: $e';
      });
    }
  }

  String getLocalizedTitle(Map<String, dynamic> course, Locale locale) {
    if (locale.languageCode == 'ar' && course['title_ar'] != null) {
      return course['title_ar'];
    }
    return course['title'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : courses.isEmpty
                  ? const Center(
                      child: Text('No courses found for this category'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return CategoryCourseCard(
                          course: course,
                          locale: locale,
                          onTap: () {
                            // Navigate to course details page
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CourseDetails(courseId: course['id']),
                            ));
                          },
                        );
                      },
                    ),
    );
  }
}

class CategoryCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Locale locale;
  final VoidCallback? onTap;

  const CategoryCourseCard({
    super.key,
    required this.course,
    required this.locale,
    this.onTap,
  });

  String getLocalizedTitle() {
    final titleMap = course['title'];
    if (titleMap is Map) {
      return titleMap[locale.languageCode] ?? titleMap['en'] ?? '';
    }
    return '';
  }

  String getInstructorUserName() {
    final instructor = course['instructor'];
    if (instructor is Map && instructor['user'] is Map) {
      final user = instructor['user'];
      // Prefer full name if available, else username
      final firstName = user['firstName']?[locale.languageCode] ??
          user['firstName']?['en'] ??
          '';
      final lastName = user['lastName']?[locale.languageCode] ??
          user['lastName']?['en'] ??
          '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
      return user['username'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final title = getLocalizedTitle();
    final thumbnail = course['thumbnail'] ?? '';
    final instructorName = getInstructorUserName();

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course thumbnail
              Expanded(
                child: thumbnail.isNotEmpty
                    ? Image.network(
                        thumbnail,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            thumbnail,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/placeholder.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              // Course title and instructor
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Instructor name
                    Text(
                      instructorName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
