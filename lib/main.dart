import 'package:almentor_clone/loginPage.dart';
import 'package:almentor_clone/signUpPage.dart';
import 'package:almentor_clone/homePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => Loginpage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
