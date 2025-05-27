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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses',
          style: theme.textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              : courses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No courses found for this category',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
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
                                  CourseDetails(courseId: course['_id']),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = getLocalizedTitle();
    final thumbnail = course['thumbnail'] ?? '';
    final instructorName = getInstructorUserName();
    final instructorImage = getInstructorImage();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with overlay gradient
            Stack(
              children: [
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
                              return Container(
                                color: isDark
                                    ? Colors.grey[850]
                                    : Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color:
                                      isDark ? Colors.white24 : Colors.black26,
                                  size: 32,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: isDark ? Colors.grey[850] : Colors.grey[200],
                            child: Icon(
                              Icons.image_outlined,
                              color: isDark ? Colors.white24 : Colors.black26,
                              size: 32,
                            ),
                          ),
                  ),
                ),
                // Add subtle gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Course details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Instructor info with improved styling
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            isDark ? Colors.grey[800] : Colors.grey[200],
                        backgroundImage: instructorImage != null &&
                                instructorImage.isNotEmpty
                            ? NetworkImage(instructorImage)
                            : null,
                        child: instructorImage == null ||
                                instructorImage.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 16,
                                color: isDark ? Colors.white38 : Colors.black38,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          instructorName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
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
