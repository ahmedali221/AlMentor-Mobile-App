import 'package:almentor_clone/pages/categories/categoryCourses.dart';
import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:almentor_clone/pages/instructors/instructors.dart';
import 'package:almentor_clone/pages/subs%20and%20payment/craditpayment.dart';
import 'package:almentor_clone/pages/subs%20and%20payment/subscribe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:almentor_clone/Core/Themes/lightTheme.dart';
import 'package:almentor_clone/Core/Themes/darkTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/auth/loginPage.dart';
import 'pages/auth/signUpPage.dart';
import 'pages/profile/account_page.dart';
import 'pages/clips_page.dart';
import 'pages/categories/search_page.dart';
import 'pages/home_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth service and check login status
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  const MyApp({super.key, this.isLoggedIn = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String initialRoute;

  @override
  void initState() {
    super.initState();
    // Set initial route based on authentication status
    initialRoute = widget.isLoggedIn ? '/home' : '/login';
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
            '/clips': (context) => const ClipsPage(),
            '/search': (context) => const SearchPage(),
            '/subscribe': (context) => SubscribePage(),
          },
        );
      },
    );
  }
}
