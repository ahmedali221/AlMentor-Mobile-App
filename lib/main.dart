import 'package:almentor_clone/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/auth/loginPage.dart';
import 'pages/auth/signUpPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialized
  runApp(const MyApp());
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: initialRoute,
      routes: {
        '/': (context) => Loginpage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
