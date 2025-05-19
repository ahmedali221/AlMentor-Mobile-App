import 'package:almentor_clone/pages/instructors/instructors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Core/Providers/themeProvider.dart';

import 'profile/account_page.dart';
import '../pages/clips_page.dart';
import 'categories/search_page.dart';
import '../pages/mainPage.dart';
import 'ai-chat/ai_mentor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 4;

  final List<Widget> _pages = const [
    AccountPage(),
    ClipsPage(),
    SearchPage(),
    Instructors(),
    MainPage(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.grey[900] : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Almentor',
          style: TextStyle(
            color: isDark
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
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
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Almentor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your Learning Companion',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.9 * 255).toInt()),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.smart_toy_outlined,
                color: Theme.of(context).primaryColor,
              ),
              title: Row(
                children: [
                  Text(
                    'Try Your Mentor',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AiMentorPage(),
                  ),
                );
              },
            ),
            Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
            ListTile(
              leading: Icon(Icons.settings,
                  color: isDark ? Colors.white : Colors.black),
              title: Text('Subscription',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/subscribe');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings,
                  color: isDark ? Colors.white : Colors.black),
              title: Text('Settings',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline,
                  color: isDark ? Colors.white : Colors.black),
              title: Text('Help & Support',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).scaffoldBackgroundColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Clips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Instructors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
      ),
    );
  }
}
