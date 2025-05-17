import 'package:almentor_clone/pages/categories/categoryCourses.dart';
import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:almentor_clone/pages/courses/courses_page.dart';
import 'package:almentor_clone/pages/instructors/instructors.dart';
import 'package:almentor_clone/pages/subs%20and%20payment/craditpayment.dart';
import 'package:almentor_clone/pages/subs%20and%20payment/subscribe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:almentor_clone/Core/Themes/lightTheme.dart';
import 'package:almentor_clone/Core/Themes/darkTheme.dart';

import 'pages/auth/loginPage.dart';
import 'pages/auth/signUpPage.dart';
import 'pages/profile/account_page.dart';
import 'pages/clips_page.dart';
import 'pages/categories/search_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? initialRoute = '/login';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Almentor Clone',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: initialRoute,
          routes: {
            '/login': (context) => Loginpage(),
            '/signup': (context) => SignUpPage(),
            '/home': (context) => const HomePage(),
            '/instructors': (context) => const Instructors(),
            '/account': (context) => const AccountPage(),
            '/courses': (context) => const CoursesPage(),
            '/clips': (context) => const ClipsPage(),
            '/search': (context) => const SearchPage(),
            '/subscribe': (context) => SubscribePage(),
          },
        );
      },
    );
  }
}
