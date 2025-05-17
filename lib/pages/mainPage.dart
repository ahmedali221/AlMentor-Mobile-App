import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Core/Providers/themeProvider.dart';
import '../Core/Custom Widgets/section_title.dart';
import '../Core/Custom Widgets/section_description.dart';
import '../Core/Custom Widgets/horizontal_course_list.dart';
import '../Core/Custom Widgets/horizontal_learning_programs.dart';
import '../Core/Custom Widgets/horizontal_most_viewed.dart';
import '../Core/Custom Widgets/horizontal_popular_courses.dart';
import '../Core/Custom Widgets/horizontal_animated_courses.dart';
import '../data/home_demo_data.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import 'courses/courses_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final CourseService _courseService = CourseService();
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _courseService.getCourses();
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
          title: const Text('Almentor'),
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to the right in RTL
            children: [
              const SizedBox(height: 16),

              // Popular Courses Section
              SectionTitle(
                title: 'الدورات الشائعة',
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CoursesPage()),
                  );
                },
              ),
              SectionDescription(
                description: 'استكشف الدورات الأكثر شعبية على المنصة',
              ),
              HorizontalPopularCourses(
                courses: HomePageDemoData.featuredCourses,
              ),

              const SizedBox(height: 24),

              // Animated Courses Section
              FutureBuilder<List<Course>>(
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
                    // If no data, show the regular course list as fallback
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          title: 'دورات مميزة',
                          onSeeAllPressed: () {},
                        ),
                        SectionDescription(
                          description: 'دورات تدريبية مختارة خصيصاً لك',
                        ),
                        HorizontalCourseList(
                          courses: HomePageDemoData.courses,
                        ),
                      ],
                    );
                  }

                  return HorizontalAnimatedCourses(
                    courses: snapshot.data!,
                    title: 'دورات مميزة',
                    description: 'دورات تدريبية مختارة خصيصاً لك',
                    onCourseTap: (course) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetails(course: course),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Learning Programs Section
              SectionTitle(
                title: 'برامج تعليمية',
                onSeeAllPressed: () {},
              ),
              SectionDescription(
                description: 'برامج متكاملة لتطوير مهاراتك',
              ),
              HorizontalLearningPrograms(
                programs: HomePageDemoData.learningPrograms,
              ),

              const SizedBox(height: 24),

              // Most Watched Section
              SectionTitle(
                title: 'الأكثر مشاهدة',
                onSeeAllPressed: () {},
              ),
              SectionDescription(
                description: 'الدورات الأكثر مشاهدة على المنصة',
              ),
              HorizontalMostViewed(
                courses: HomePageDemoData.mostWatched,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
