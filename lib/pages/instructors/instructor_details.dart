import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/instructor.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../Core/Providers/themeProvider.dart';
import '../courses/coursesDetails.dart';

class InstructorDetailsPage extends StatefulWidget {
  final Instructor instructor;
  final bool isArabic;

  const InstructorDetailsPage({
    super.key,
    required this.instructor,
    this.isArabic = false,
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
    final isArabic = widget.isArabic;
    final instructor = widget.instructor;
    final user = instructor.user;

    final String firstName = isArabic ? user.firstNameAr : user.firstNameEn;
    final String lastName = isArabic ? user.lastNameAr : user.lastNameEn;
    final String professionalTitle = isArabic
        ? instructor.professionalTitleAr
        : instructor.professionalTitleEn;
    final List<String> expertiseAreas =
        isArabic ? instructor.expertiseAr : instructor.expertiseEn;
    final String biography =
        isArabic ? instructor.biographyAr : instructor.biographyEn;
    final String profilePicture = user.profilePicture;

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
                isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
            ],
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
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: profilePicture.isNotEmpty
                                ? NetworkImage(profilePicture)
                                : null,
                            child: profilePicture.isEmpty
                                ? Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$firstName $lastName',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      isArabic ? 'مجالات الخبرة' : 'Expertise Areas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: expertiseAreas
                          .map((area) => Chip(
                                label: Text(area),
                                labelStyle: TextStyle(color: Colors.black),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Biography
                  Text(
                    isArabic ? 'السيرة الذاتية' : 'Biography',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
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
                  ),
                  const SizedBox(height: 32),
                  // Courses Section
                  Text(
                    isArabic
                        ? 'الدورات المقدمة من هذا المدرب'
                        : 'Courses by this Instructor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                          ? Center(child: Text(errorMessage))
                          : instructorCourses.isEmpty
                              ? Center(
                                  child: Text(
                                    isArabic
                                        ? 'لا توجد دورات متاحة لهذا المدرب'
                                        : 'No courses available from this instructor',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: instructorCourses.length,
                                  itemBuilder: (context, index) {
                                    final course = instructorCourses[index];
                                    final locale =
                                        Localizations.localeOf(context);

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CourseDetails(
                                                courseId: course.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Course thumbnail
                                            AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Image.network(
                                                course.thumbnail,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(Icons.error),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    course.getLocalizedTitle(
                                                        locale),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.access_time,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[600]),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${(course.duration / 60).round()} ${isArabic ? "دقيقة" : "minutes"}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 12),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Icon(Icons.star,
                                                          size: 14,
                                                          color: Colors.amber),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${course.rating.average.toStringAsFixed(1)}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 12),
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
