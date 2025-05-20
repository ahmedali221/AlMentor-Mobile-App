import 'package:almentor_clone/Core/Localization/app_translations.dart';
import 'package:almentor_clone/Core/Providers/language_provider.dart';
import 'package:almentor_clone/pages/instructors/instructors.dart';
import 'package:almentor_clone/pages/my%20courses/userCourses.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';

import '../profile/account_page.dart';
import '../clips_page.dart';
import '../categories/search_page.dart';
import '../mainPage.dart';
import '../ai-chat/ai_mentor_page.dart';

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
    UserCourses(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = languageProvider.currentLocale.languageCode;
    final isRtl = languageProvider.isArabic;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.grey[900] : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          AppTranslations.getText('app_name', locale),
          style: TextStyle(
            color: isDark
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          // Language switcher
          TextButton(
            onPressed: () {
              languageProvider.changeLanguage(isRtl ? 'en' : 'ar');
            },
            child: Text(
              isRtl ? 'English' : 'العربية',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          // Theme switcher
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
                    AppTranslations.getText('app_name', locale),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppTranslations.getText('app_subtitle', locale),
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
                    AppTranslations.getText('try_mentor', locale),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppTranslations.getText('new_badge', locale),
                      style: const TextStyle(
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
                    builder: (context) => const AiMentorPage(),
                  ),
                );
              },
            ),
            Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
            // Drawer menu items
            _buildDrawerItem(
              context,
              Icons.card_membership,
              'subscription',
              isDark,
              () => Navigator.pushNamed(context, '/subscribe'),
            ),
            _buildDrawerItem(
              context,
              Icons.settings,
              'settings',
              isDark,
              () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              context,
              Icons.help_outline,
              'help_support',
              isDark,
              () => Navigator.pop(context),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppTranslations.getText('nav_account', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.video_library),
            label: AppTranslations.getText('nav_clips', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: AppTranslations.getText('nav_search', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school),
            label: AppTranslations.getText('nav_instructors', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppTranslations.getText('nav_home', locale),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: AppTranslations.getText('nav_my_courses', locale),
          ),
        ],
      ),
    );
  }
}

Widget _buildDrawerItem(BuildContext context, IconData icon, String textKey,
    bool isDark, VoidCallback onTap) {
  final locale =
      Provider.of<LanguageProvider>(context).currentLocale.languageCode;

  return ListTile(
    leading: Icon(icon, color: isDark ? Colors.white : Colors.black),
    title: Text(
      AppTranslations.getText(textKey, locale),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
    ),
    onTap: onTap,
  );
}
