import 'package:flutter/material.dart';
import '../Guards/auth_guard.dart';
import '../../pages/courses/lessonsViewr.dart';
import '../../pages/home_page.dart';
import '../../pages/courses/coursesDetails.dart';
import '../../pages/Programs/ProgramDetails.dart';
import '../../pages/instructors/instructor_details.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());

      case '/lessons_viewer':
        if (args == null ||
            !args.containsKey('course') ||
            !args.containsKey('modules') ||
            !args.containsKey('lessons') ||
            !args.containsKey('initialIndex')) {
          return _errorRoute();
        }
        return MaterialPageRoute(
          builder: (_) => AuthGuard(
            child: LessonViewerPage(
              course: args['course'],
              modules: args['modules'],
              lessons: args['lessons'],
              initialIndex: args['initialIndex'] as int,
            ),
          ),
        );

      case '/course_details':
        if (args == null || !args.containsKey('courseId')) {
          return _errorRoute();
        }
        return MaterialPageRoute(
          builder: (_) => CourseDetails(courseId: args['courseId']),
        );

      case '/program_details':
        if (args == null || !args.containsKey('programId')) {
          return _errorRoute();
        }
        return MaterialPageRoute(
          builder: (_) => ProgramDetails(programId: args['programId']),
        );

      case '/instructor_details':
        if (args == null || !args.containsKey('instructorId')) {
          return _errorRoute();
        }
        return MaterialPageRoute(
          builder: (_) => InstructorDetailsPage(
            instructor: args[
                'instructor'], // Changed to pass the full instructor object
            isArabic: args['isArabic'] ?? false,
          ),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Invalid route parameters or page not found'),
        ),
      ),
    );
  }
}
