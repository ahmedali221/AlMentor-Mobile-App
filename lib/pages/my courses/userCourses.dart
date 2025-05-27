import 'dart:math' as Math;

import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/saved_course_service.dart';
import '../../models/course.dart';
import '../../Core/Localization/app_translations.dart';
import '../../Core/Providers/language_provider.dart';
import '../../Core/Providers/themeProvider.dart';
import 'package:logging/logging.dart';

class UserCourses extends StatefulWidget {
  const UserCourses({super.key});

  @override
  State<UserCourses> createState() => _UserCoursesState();
}

class _UserCoursesState extends State<UserCourses> {
  final AuthService _authService = AuthService();
  final SavedCourseService _savedCourseService = SavedCourseService();
  final Logger _logger = Logger('UserCoursesPage');

  bool _isLoading = true;
  bool _isAuthenticated = false;
  List<Course> _savedCourses = [];
  String? _userId;
  String? _error;
  bool _isRefreshing = false;
  Map<String, dynamic>? _lastApiResponse;

  @override
  void initState() {
    super.initState();
    _logger.info('UserCourses page initialized');
    _initPage();
  }

  Future<void> _initPage() async {
    _logger.info('Step 1: Checking authentication...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      _logger.info('Step 2: isLoggedIn = $isLoggedIn');

      if (!isLoggedIn) {
        if (mounted) {
          _logger.warning('User not logged in');
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
          });
          _showAuthDialog();
        }
        return;
      }

      // Get user_id from SharedPreferences
      _logger.info('Step 3: Getting user_id from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      _logger.info('user_id from local storage: $userId');

      if (userId == null || userId.isEmpty) {
        _logger.severe('User ID not found in SharedPreferences');
        if (mounted) {
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
            _error = 'User ID not found. Please log in again.';
          });
          _showAuthDialog();
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _userId = userId;
        });
      }

      // Fetch saved courses
      await _fetchUserCourses();
    } catch (e, stackTrace) {
      _logger.severe('Error during initialization', e, stackTrace);
      if (mounted) {
        setState(() {
          _error = 'Error initializing page: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserCourses() async {
    _logger.info('Step 4: Fetching saved courses from API...');
    if (mounted) {
      setState(() {
        _isLoading =
            !_isRefreshing; // Only show loading indicator if not refreshing
        _error = null;
      });
    }

    try {
      // Debug: Check authentication status before API call
      final token = await _authService.getToken();
      _logger.info('Auth token available: ${token != null}');

      final courses =
          await _savedCourseService.getSavedCourses(forceRefresh: true);
      _logger.info('Step 5: Saved courses fetched successfully!');
      _logger.info('Saved courses count: ${courses.length}');

      // Debug: Log each course's basic info
      for (var i = 0; i < courses.length; i++) {
        final course = courses[i];
        _logger.info(
            'Course $i - ID: ${course.id}, Title: ${course.title['en']}, ' +
                'Thumbnail: ${course.thumbnail.isNotEmpty ? "Available" : "Missing"}');
        _logger.info('Course $i - Instructor: ${course.instructor.id}, ' +
            'Instructor Name: ${course.instructor.user.firstNameEn} ${course.instructor.user.lastNameEn}');
      }

      // Filter out courses with empty IDs
      final validCourses =
          courses.where((course) => course.id.isNotEmpty).toList();
      if (validCourses.length != courses.length) {
        _logger.warning(
            'Filtered out ${courses.length - validCourses.length} courses with empty IDs');
      }

      if (mounted) {
        setState(() {
          _savedCourses = validCourses;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e, stackTrace) {
      _logger.severe('Error fetching saved courses: $e', e, stackTrace);
      if (mounted) {
        setState(() {
          _error = 'Error loading courses: $e';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshCourses() async {
    _logger.info('Refreshing courses...');
    setState(() {
      _isRefreshing = true;
    });
    await _fetchUserCourses();
  }

  Future<bool> _unsaveCourse(String courseId) async {
    _logger.info('Attempting to unsave course: $courseId');
    try {
      final result = await _savedCourseService.unsaveCourse(courseId);
      if (result) {
        _logger.info('Course unsaved successfully');
        // Remove the course from the local list
        setState(() {
          _savedCourses.removeWhere((course) => course.id == courseId);
        });
        return true;
      } else {
        _logger.warning('Failed to unsave course: $courseId');
        return false;
      }
    } catch (e) {
      _logger.severe('Error unsaving course: $e');
      return false;
    }
  }

  void _showAuthDialog() {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final locale = languageProvider.currentLocale.languageCode;
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Text(
          AppTranslations.getText('authentication_required', locale) ??
              'Authentication Required',
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

  Widget _buildCourseItem(Course course, String locale, bool isDark) {
    // Debug: Add visual indicators for missing data
    final hasThumbnail = course.thumbnail.isNotEmpty;
    final hasTitle = course.getLocalizedTitle(Locale(locale)).isNotEmpty;
    final hasDescription =
        course.getLocalizedDescription(Locale(locale)).isNotEmpty;

    return Card(
      color: isDark ? Colors.grey[850] : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: hasThumbnail
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      course.thumbnail,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        _logger.warning(
                            'Failed to load thumbnail: ${course.thumbnail}');
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child:
                              Icon(Icons.broken_image, color: Colors.grey[700]),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.red[100], // Highlight missing thumbnails
                    child: Icon(Icons.image_not_supported, color: Colors.red),
                  ),
            title: Text(
              hasTitle
                  ? course.getLocalizedTitle(Locale(locale))
                  : '[Missing Title]', // Debug indicator
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Remove Course'),
                        content: Text(
                            'Are you sure you want to remove this course from your saved list?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Remove',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirmed) {
                  final success = await _unsaveCourse(course.id);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Course removed from saved list')),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to remove course')),
                    );
                  }
                }
              },
            ),
            onTap: () {
              // Navigate to course details
              _logger.info('Navigating to course details: ${course.id}');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CourseDetails(courseId: course.id),
                ),
              );
            },
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

    if (_isLoading) {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                'Loading your courses...',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
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
        body: Center(
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
                  AppTranslations.getText('login_required_message', locale) ??
                      'Please login to view your courses',
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
        actions: [
          // Debug button to show raw API response
          IconButton(
            icon: Icon(Icons.bug_report,
                color: isDark ? Colors.white70 : Colors.black54),
            onPressed: _lastApiResponse != null
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Debug: API Response'),
                        content: SingleChildScrollView(
                          child: Text(_lastApiResponse.toString()),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCourses,
        child: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error Loading Courses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshCourses,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            : _savedCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppTranslations.getText('no_saved_courses', locale) ??
                              'You have no saved courses.',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Navigate to courses page
                            Navigator.of(context).pushNamed('/courses');
                          },
                          child: Text(
                            AppTranslations.getText(
                                    'explore_courses', locale) ??
                                'Explore Courses',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _savedCourses.length,
                    padding: EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final course = _savedCourses[index];
                      return _buildCourseItem(course, locale, isDark);
                    },
                  ),
      ),
    );
  }
}
