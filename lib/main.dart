import 'package:flutter/material.dart';
import 'pages/account_page.dart';
import 'pages/my_courses_page.dart';
import 'pages/clips_page.dart';
import 'pages/search_page.dart';
import 'pages/home_page.dart';
import 'widgets/custom_bottom_nav_bar.dart';

// import 'pages/auth/loginPage.dart';
// import 'pages/auth/signUpPage.dart';

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
        // '/': (context) => Loginpage(),
        // '/signup': (context) => SignUpPage(),
        '/': (context) => const MainHomeContent(),
        '/account': (context) => const AccountPage(),
        '/courses': (context) => const MyCoursesPage(),
        '/clips': (context) => const ClipsPage(),
        '/search': (context) => const SearchPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 4; // Home is selected by default

  final List<Widget> _pages = const [
    AccountPage(),
    MyCoursesPage(),
    ClipsPage(),
    SearchPage(),
    MainHomeContent(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
