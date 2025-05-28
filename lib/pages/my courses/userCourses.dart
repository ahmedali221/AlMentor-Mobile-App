import 'dart:math' as Math;
import 'package:almentor_clone/Core/Providers/language_provider.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:almentor_clone/models/userSavedCourses.dart';
import 'package:almentor_clone/pages/courses/coursesDetails.dart';

import '../../services/saved_course_service.dart';
import 'package:almentor_clone/Core/Localization/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../../services/auth_service.dart';

class UserCoursesPage extends StatefulWidget {
  @override
  _UserCoursesPageState createState() => _UserCoursesPageState();
}

class _UserCoursesPageState extends State<UserCoursesPage> {
  final SavedCourseService _savedCourseService = SavedCourseService();
  final AuthService _authService = AuthService();
  final Logger _logger = Logger('UserCoursesPage');

  List<UserSavedCourse> _savedCourses = [];
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _userId;
  String? _error;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (!isLoggedIn) {
        if (mounted) {
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
          });
          _showAuthDialog();
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null || userId.isEmpty) {
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

      await _fetchUserCourses();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error initializing page: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserCourses() async {
    try {
      final savedCourses = await _savedCourseService.getUserSavedCourses();
      setState(() {
        _savedCourses = savedCourses;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCourses() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchUserCourses();
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<bool> _unsaveCourse(String courseId) async {
    try {
      final success = await _savedCourseService.unsaveCourse(courseId);
      if (success) {
        setState(() {
          _savedCourses.removeWhere((savedCourse) =>
              (savedCourse.course['_id'] == courseId) ||
              (savedCourse.course['id'] == courseId));
        });
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Authentication Required'),
        content: Text('You need to be logged in to view your courses.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _authService.saveTargetRoute('/user_courses');
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }

  // --- UTILS for safe field access ---
  String _getTitle(Map course, String locale) {
    try {
      if (course['title'] is Map) {
        return course['title'][locale] ?? course['title']['en'] ?? '';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  String _getDescription(Map course, String locale) {
    try {
      if (course['description'] is Map) {
        return course['description'][locale] ??
            course['description']['en'] ??
            '';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  String? _getThumbnail(Map course) {
    try {
      return course['thumbnail'] as String? ??
          'https://via.placeholder.com/400x200';
    } catch (_) {
      return 'https://via.placeholder.com/400x200';
    }
  }

  bool _isCourseFree(Map course) {
    try {
      return course['isFree'] == true;
    } catch (_) {
      return false;
    }
  }

  String _getLevel(Map course, String locale) {
    try {
      if (course['level'] is Map) {
        return course['level'][locale] ?? course['level']['en'] ?? '';
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  int _getDuration(Map course) {
    try {
      return course['duration'] is int
          ? course['duration']
          : int.tryParse(course['duration'].toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String _getCourseId(Map course) {
    try {
      return course['_id'] ?? course['id'] ?? '';
    } catch (_) {
      return '';
    }
  }

  // --- END UTILS ---

  Widget _buildCourseItem(
      UserSavedCourse savedCourse, String locale, bool isDark) {
    final course = savedCourse.course;
    final courseId = _getCourseId(course);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  _getThumbnail(course) ??
                      'https://via.placeholder.com/400x200',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bookmark icon in top right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () async {
                    // Confirm before unsaving
                    final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Unsave Course?'),
                            content: Text(
                                'Are you sure you want to remove this course from your saved list?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Unsave'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirmed) {
                      final success = await _unsaveCourse(courseId);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Course removed from saved list'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to remove course'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      Icons.bookmark, // Always filled since all here are saved
                      key: ValueKey('bookmark_${courseId}_saved'),
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getTitle(course, locale) ?? 'Untitled Course',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isCourseFree(course)
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _isCourseFree(course)
                              ? AppTranslations.getText('free', locale) ??
                                  'Free'
                              : AppTranslations.getText('paid', locale) ??
                                  'Paid',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getDescription(course, locale) ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${_getDuration(course)} ${AppTranslations.getText('minutes', locale) ?? 'minutes'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.bar_chart,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getLevel(course, locale) ?? 'All Levels',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Saved: ${_formatDate(savedCourse.savedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              // Navigate to course details, use your route here.
              print('Navigating to course details: $courseId');
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CourseDetails(courseId: courseId),
              ));
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
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
          if (_savedCourses.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_savedCourses.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
                      final savedCourse = _savedCourses[index];
                      return _buildCourseItem(savedCourse, locale, isDark);
                    },
                  ),
      ),
    );
  }
}
