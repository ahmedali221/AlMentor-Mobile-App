import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../Core/Custom Widgets/horizontal_animated_courses.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage>
    with SingleTickerProviderStateMixin {
  final CourseService _courseService = CourseService();
  late Future<List<Course>> _coursesFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _courseService.getCourses();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final locale = Localizations.localeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl, // Set RTL direction for Arabic content
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            locale.languageCode == 'ar' ? 'الدورات' : 'Courses',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          actions: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: FutureBuilder<List<Course>>(
            future: _coursesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading courses: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    locale.languageCode == 'ar'
                        ? 'لا توجد دورات متاحة'
                        : 'No courses available',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }

              final courses = snapshot.data!;

              // Group courses by level
              final beginnerCourses = courses
                  .where((c) =>
                      c.getLocalizedLevel(locale) ==
                      (locale.languageCode == 'ar' ? 'مبتدئ' : 'beginner'))
                  .toList();

              final intermediateCourses = courses
                  .where((c) =>
                      c.getLocalizedLevel(locale) ==
                      (locale.languageCode == 'ar' ? 'متوسط' : 'intermediate'))
                  .toList();

              final advancedCourses = courses
                  .where((c) =>
                      c.getLocalizedLevel(locale) ==
                      (locale.languageCode == 'ar' ? 'متقدم' : 'advanced'))
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Beginner Courses
                    if (beginnerCourses.isNotEmpty)
                      HorizontalAnimatedCourses(
                        courses: beginnerCourses,
                        title: locale.languageCode == 'ar'
                            ? 'دورات للمبتدئين'
                            : 'Beginner Courses',
                        description: locale.languageCode == 'ar'
                            ? 'دورات مناسبة للمبتدئين في هذا المجال'
                            : 'Courses suitable for beginners in this field',
                        onCourseTap: (course) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CourseDetails(course: course),
                          ));
                        },
                      ),

                    // Intermediate Courses
                    if (intermediateCourses.isNotEmpty)
                      HorizontalAnimatedCourses(
                        courses: intermediateCourses,
                        title: locale.languageCode == 'ar'
                            ? 'دورات متوسطة المستوى'
                            : 'Intermediate Courses',
                        description: locale.languageCode == 'ar'
                            ? 'دورات للمتعلمين ذوي المستوى المتوسط'
                            : 'Courses for learners with intermediate knowledge',
                        onCourseTap: (course) {
                          // Navigate to course details page
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Selected: ${course.getLocalizedTitle(locale)}')));
                        },
                      ),

                    // Advanced Courses
                    if (advancedCourses.isNotEmpty)
                      HorizontalAnimatedCourses(
                        courses: advancedCourses,
                        title: locale.languageCode == 'ar'
                            ? 'دورات متقدمة'
                            : 'Advanced Courses',
                        description: locale.languageCode == 'ar'
                            ? 'دورات متقدمة للمحترفين'
                            : 'Advanced courses for professionals',
                        onCourseTap: (course) {
                          // Navigate to course details page
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Selected: ${course.getLocalizedTitle(locale)}')));
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
