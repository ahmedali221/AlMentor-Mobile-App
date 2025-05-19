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
    this.isArabic = false, // set this based on your app's locale
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

      print('Fetching courses for instructor: ${widget.instructor.id}');
      final courses = await _courseService.getCoursesByInstructor(widget.instructor.id);
      print('Fetched ${courses.length} courses for instructor');

      setState(() {
        instructorCourses = courses;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching instructor courses: $e');
      setState(() {
        errorMessage = 'Failed to load instructor courses: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Choose language based on isArabic flag
    final String firstName =
        widget.isArabic ? widget.instructor.user.firstNameAr : widget.instructor.user.firstNameEn;
    final String lastName =
        widget.isArabic ? widget.instructor.user.lastNameAr : widget.instructor.user.lastNameEn;
    final String professionalTitle = widget.isArabic
        ? widget.instructor.professionalTitleAr
        : widget.instructor.professionalTitleEn;
    final List<String> expertiseAreas =
        widget.isArabic ? widget.instructor.expertiseAr : widget.instructor.expertiseEn;
    final String biography =
        widget.isArabic ? widget.instructor.biographyAr : widget.instructor.biographyEn;
    final String profilePicture = widget.instructor.user.profilePicture;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('$firstName $lastName'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile picture
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  profilePicture.isNotEmpty
                      ? CircleAvatar(
                          radius: 75,
                          backgroundImage: NetworkImage(profilePicture),
                          onBackgroundImageError: (e, s) =>
                              const Icon(Icons.person),
                        )
                      : CircleAvatar(
                          radius: 75,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  Text(
                    '$firstName $lastName',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    professionalTitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Expertise Areas
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expertise Areas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: expertiseAreas.map((area) {
                      return Chip(
                        label: Text(area),
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Biography
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biography',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    biography,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Instructor Courses
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Courses by this Instructor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                          ? Center(child: Text(errorMessage))
                          : instructorCourses.isEmpty
                              ? Center(
                                  child: Text(
                                    'No courses available from this instructor',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.6),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: instructorCourses.length,
                                  itemBuilder: (context, index) {
                                    final course = instructorCourses[index];
                                    final locale = Localizations.localeOf(context);
                                    
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CourseDetails(
                                                courseId: course.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Course thumbnail
                                            AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Image.network(
                                                course.thumbnail,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
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
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    course.getLocalizedTitle(locale),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.access_time,
                                                          size: 14, color: Colors.grey[600]),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${(course.duration / 60).round()} minutes',
                                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Icon(Icons.star,
                                                          size: 14, color: Colors.amber),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${course.rating.average.toStringAsFixed(1)}',
                                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
          ],
        ),
      ),
    );
  }
}
