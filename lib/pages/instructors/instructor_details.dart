import 'package:almentor_clone/Core/Localization/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/instructor.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../Core/Providers/themeProvider.dart';
import '../courses/coursesDetails.dart';

class InstructorDetailsPage extends StatefulWidget {
  final Instructor instructor;
  final String locale;
  final bool isRtl;

  const InstructorDetailsPage({
    super.key,
    required this.instructor,
    required this.locale,
    required this.isRtl,
  });

  @override
  State<InstructorDetailsPage> createState() => _InstructorDetailsPageState();
}

class _InstructorDetailsPageState extends State<InstructorDetailsPage> {
  final CourseService _courseService = CourseService();
  List<Course> instructorCourses = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchInstructorCourses();
  }

  Future<void> fetchInstructorCourses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
      final courses =
          await _courseService.getCoursesByInstructor(widget.instructor.id);
      setState(() {
        instructorCourses = courses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load instructor courses: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final instructor = widget.instructor;
    final user = instructor.user;
    final isRtl = widget.isRtl;
    final locale = widget.locale;

    final String name = locale == 'ar'
        ? '${user.firstNameAr} ${user.lastNameAr}'
        : '${user.firstNameEn} ${user.lastNameEn}';
    final String professionalTitle = locale == 'ar'
        ? instructor.professionalTitleAr
        : instructor.professionalTitleEn;
    final List<String> expertiseAreas =
        locale == 'ar' ? instructor.expertiseAr : instructor.expertiseEn;
    final String biography =
        locale == 'ar' ? instructor.biographyAr : instructor.biographyEn;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: CustomScrollView(
        slivers: [
          // Collapsible AppBar with background and avatar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            leading: IconButton(
              icon: Icon(
                isRtl ? Icons.arrow_forward : Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppTranslations.getText('instructor_details', locale),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image or color
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.7),
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Profile picture and info
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: isRtl
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: user.profilePicture.isNotEmpty
                                ? NetworkImage(user.profilePicture)
                                : null,
                            child: user.profilePicture.isEmpty
                                ? Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            name,
                            textAlign: isRtl ? TextAlign.right : TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            professionalTitle,
                            textAlign: isRtl ? TextAlign.right : TextAlign.left,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Social Media Links
                  if (instructor.socialMediaLinks.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          instructor.socialMediaLinks.entries.map((entry) {
                        final icon = _getSocialIcon(entry.key);
                        return IconButton(
                          icon: icon,
                          onPressed: () {
                            if (entry.value.isNotEmpty) {
                              _launchURL(entry.value);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  // Expertise Areas
                  if (expertiseAreas.isNotEmpty) ...[
                    Text(
                      AppTranslations.getText('expertise_areas', locale),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: expertiseAreas
                          .map((area) => Chip(
                                label: Text(
                                  area,
                                  textAlign:
                                      isRtl ? TextAlign.right : TextAlign.left,
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Biography
                  Text(
                    AppTranslations.getText('biography', locale),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    biography,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark
                          ? Colors.white.withOpacity(0.85)
                          : Colors.black87,
                    ),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 32),
                  // Courses Section
                  Text(
                    AppTranslations.getText('instructor_courses', locale),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(
                            AppTranslations.getText('loading_courses', locale),
                          ),
                        ],
                      ),
                    )
                  else if (errorMessage.isNotEmpty)
                    Center(
                      child: Text(
                        AppTranslations.getText(
                              'error_loading_courses',
                              locale,
                            ) +
                            errorMessage,
                      ),
                    )
                  else if (instructorCourses.isEmpty)
                    Center(
                      child: Text(
                        AppTranslations.getText('no_courses', locale),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: instructorCourses.length,
                      itemBuilder: (context, index) {
                        final course = instructorCourses[index];
                        return _CourseCard(
                          course: course,
                          isDark: isDark,
                          isRtl: isRtl,
                          locale: locale,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon _getSocialIcon(String key) {
    switch (key.toLowerCase()) {
      case 'linkedin':
        return const Icon(Icons.business, color: Colors.blue);
      case 'twitter':
        return const Icon(Icons.alternate_email, color: Colors.lightBlue);
      case 'youtube':
        return const Icon(Icons.ondemand_video, color: Colors.red);
      case 'website':
        return const Icon(Icons.language, color: Colors.green);
      default:
        return const Icon(Icons.link);
    }
  }

  void _launchURL(String url) async {}
}

// Add a separate CourseCard widget for better organization
class _CourseCard extends StatelessWidget {
  final Course course;
  final bool isDark;
  final bool isRtl;
  final String locale;

  const _CourseCard({
    required this.course,
    required this.isDark,
    required this.isRtl,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetails(courseId: course.id),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                course.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                    isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    locale == 'ar'
                        ? (course.title['ar'] ?? '')
                        : (course.title['en'] ?? ''),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                        isRtl ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${(course.duration / 60).round()} ${AppTranslations.getText('minutes', locale)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        course.rating.average.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ].reversed.toList(),
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
