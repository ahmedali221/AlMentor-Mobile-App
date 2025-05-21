import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../Core/Localization/app_translations.dart';
import '../../Core/Providers/language_provider.dart';
import '../../Core/Providers/themeProvider.dart';

class UserCourses extends StatefulWidget {
  const UserCourses({super.key});

  @override
  State<UserCourses> createState() => _UserCoursesState();
}

class _UserCoursesState extends State<UserCourses> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    setState(() {
      _isLoading = true;
    });

    final isLoggedIn = await _authService.isLoggedIn();

    if (mounted) {
      setState(() {
        _isAuthenticated = isLoggedIn;
        _isLoading = false;
      });

      if (!isLoggedIn) {
        _showAuthDialog();
      }
    }
  }

  void _showAuthDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final locale = languageProvider.currentLocale.languageCode;
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Text(
          AppTranslations.getText('authentication_required', locale) ?? 'Authentication Required',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppTranslations.getText('login_required_courses', locale) ?? 
                      'You need to be logged in to view your courses',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: Text(
              AppTranslations.getText('cancel', locale) ?? 'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _authService.saveTargetRoute('/user_courses');
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text(
              AppTranslations.getText('login', locale) ?? 'Sign In',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final locale = languageProvider.currentLocale.languageCode;
    final isDark = themeProvider.isDarkMode;
    final isRtl = languageProvider.isArabic;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        elevation: 0,
        title: Text(
          AppTranslations.getText('nav_my_courses', locale) ?? 'My Courses',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: _isAuthenticated
          ? Center(
              child: Text(
                AppTranslations.getText('loading_courses', locale) ?? 'Loading your courses...',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 64,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppTranslations.getText(
                        'login_required_message',
                        locale
                      ) ?? 'Please login to view your courses',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        await _authService.saveTargetRoute('/user_courses');
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text(
                        AppTranslations.getText('login', locale) ?? 'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
