import 'package:almentor_clone/pages/homePage.dart';
import 'package:almentor_clone/pages/instructors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:almentor_clone/Core/Themes/lightTheme.dart';
import 'package:almentor_clone/Core/Themes/darkTheme.dart';

import 'pages/auth/signUpPage.dart';

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
  String? initialRoute;

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
          title: 'Flutter Demo',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: initialRoute,
          routes: {
            '/': (context) => const HomePage(),
            '/signup': (context) => SignUpPage(),
            '/home': (context) => const HomePage(),
            '/instructors': (context) => const Instructors(),
          },
        );
      },
    );
  }
}
