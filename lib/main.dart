import 'package:almentor_clone/pages/homePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/auth/loginPage.dart';
import 'pages/auth/signUpPage.dart';

void main() {
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
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    setState(() {
      initialRoute = (token != null && token.isNotEmpty) ? '/home' : '/';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (initialRoute == null) {
      // Show splash/loading screen while checking login status
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
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
