import 'package:almentor_clone/Core/Localization/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Guards/auth_guard.dart';
import '../../pages/courses/lessonsViewr.dart';
import '../../pages/home/home_page.dart';
import '../../pages/courses/coursesDetails.dart';
import '../../pages/Programs/ProgramDetails.dart';
import '../../pages/instructors/instructor_details.dart';
import '../../pages/my courses/userCourses.dart';
import '../../pages/auth/loginPage.dart';
import '../Providers/language_provider.dart';

class RouteGenerator {
  static const _protectedRoutes = [
    '/user_courses',
    '/lessons_viewer',
  ];

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final requiresAuth = _protectedRoutes.contains(settings.name);

    Widget wrapWithAuthGuardIfNeeded(Widget page) {
      return requiresAuth
          ? AuthGuard(
              child: page,
              requiresAuth: true,
              targetRoute: settings.name,
            )
          : page;
    }

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/user_courses':
        return MaterialPageRoute(
          builder: (_) => wrapWithAuthGuardIfNeeded(const UserCourses()),
        );

      case '/lessons_viewer':
        if (args == null ||
            !args.containsKey('course') ||
            !args.containsKey('modules') ||
            !args.containsKey('lessons') ||
            !args.containsKey('initialIndex')) {
          return _errorRoute();
        }
        return MaterialPageRoute(
          builder: (_) => wrapWithAuthGuardIfNeeded(
            LessonViewerPage(
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
        if (args == null || !args.containsKey('instructor')) {
          return _errorRoute();
        }
        return MaterialPageRoute(
          builder: (context) {
            final languageProvider = Provider.of<LanguageProvider>(context);
            return InstructorDetailsPage(
              instructor: args['instructor'],
              locale: languageProvider.currentLocale.languageCode,
              isRtl: languageProvider.isArabic,
            );
          },
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        final languageProvider = Provider.of<LanguageProvider>(context);
        final locale = languageProvider.currentLocale.languageCode;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppTranslations.getText('error_title', locale)),
          ),
          body: Center(
            child: Text(AppTranslations.getText('error_route_message', locale)),
          ),
        );
      },
    );
  }
}
