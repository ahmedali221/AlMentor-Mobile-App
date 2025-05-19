import 'package:almentor_clone/pages/Lessons/lessonsPage.dart';
import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Core/Constants/apiConstants.dart';

class CategoryCourses extends StatefulWidget {
  final String categoryId;

  const CategoryCourses({super.key, required this.categoryId});

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
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/courses/category/${widget.categoryId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[100],
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
                        childAspectRatio: 0.68,
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
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  LessonsPage(courseId: course['_id']),
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
      final firstName = user['firstName']?[locale.languageCode] ??
          user['firstName']?['en'] ??
          '';
      final lastName = user['lastName']?[locale.languageCode] ??
          user['lastName']?['en'] ??
          '';
      return '$firstName $lastName'.trim();
    }
    return '';
  }

  String? getInstructorImage() {
    final instructor = course['instructor'];
    if (instructor is Map && instructor['user'] is Map) {
      return instructor['user']['profilePicture'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final title = getLocalizedTitle();
    final thumbnail = course['thumbnail'] ?? '';
    final instructorName = getInstructorUserName();
    final instructorImage = getInstructorImage();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: thumbnail.isNotEmpty
                    ? Image.network(
                        thumbnail,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/placeholder.png');
                        },
                      )
                    : Image.asset('assets/images/placeholder.png'),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Instructor info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: instructorImage != null &&
                                instructorImage.isNotEmpty
                            ? NetworkImage(instructorImage)
                            : null,
                        child: instructorImage == null
                            ? const Icon(Icons.person,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          instructorName,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
