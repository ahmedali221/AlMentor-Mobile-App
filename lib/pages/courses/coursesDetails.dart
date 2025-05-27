import 'package:almentor_clone/models/module.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/image_utils.dart';
import '../../services/saved_course_service.dart';

import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/course_service.dart';
import '../../services/module_service.dart';
import '../../services/lesson_service.dart';
import '../../services/auth_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../Core/Constants/apiConstants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';

final _logger = Logger('CourseDetails');

// Service class to handle course saving API interactions
class CourseSaveService {
  final String baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();

  // Get auth token from shared preferences
  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  // Get user ID from shared preferences
  Future<String?> _getUserId() async {
    final user = await _authService.getCurrentUser();
    return user?.id;
  }

  // Check if a course is saved by the current user
  Future<bool> checkIfCourseSaved(String courseId) async {
    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId == null || token == null) {
        return false; // User not authenticated
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/saved-courses/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.info('Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The response should be a list of saved courses, check if courseId is in the list
        if (data is List) {
          return data.any((course) =>
              course['id'] == courseId || course['_id'] == courseId);
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List).any((course) =>
              course['id'] == courseId || course['_id'] == courseId);
        }
        return false;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 500) {
        _logger.severe('Server error: ${response.body}');
        throw Exception('A server error occurred. Please try again later.');
      } else {
        _logger.warning('Failed to check saved status: ${response.body}');
        throw Exception(
            'Failed to check saved status. (${response.statusCode})');
      }
    } catch (e) {
      _logger.severe('Could not check saved status: $e');
      throw Exception('Could not check saved status. Please try again.');
    }
  }

  // Save a course
  Future<bool> saveCourse(String courseId) async {
    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId == null || token == null) {
        throw Exception('You must be logged in to save a course.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/saved-courses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'userId': userId, 'courseId': courseId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 500) {
        _logger.severe('Server error: ${response.body}');
        throw Exception('A server error occurred. Please try again later.');
      } else {
        _logger.warning('Failed to save course: ${response.body}');
        throw Exception('Failed to save course. (${response.statusCode})');
      }
    } catch (e) {
      _logger.severe('Could not save course: $e');
      throw Exception('Could not save course. Please try again.');
    }
  }

  // Unsave a course
  Future<bool> unsaveCourse(String courseId) async {
    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId == null || token == null) {
        throw Exception('You must be logged in to unsave a course.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/saved-courses/$userId/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 500) {
        _logger.severe('Server error: ${response.body}');
        throw Exception('A server error occurred. Please try again later.');
      } else {
        _logger.warning('Failed to unsave course: ${response.body}');
        throw Exception('Failed to unsave course. (${response.statusCode})');
      }
    } catch (e) {
      _logger.severe('Could not unsave course: $e');
      throw Exception('Could not unsave course. Please try again.');
    }
  }

  // Get all saved courses
  Future<List<Course>> getSavedCourses() async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/saved-courses/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.info('Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        _logger.info('Saved courses response: $responseData');

        List<dynamic> coursesList;
        if (responseData is List) {
          coursesList = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          coursesList = responseData['data'];
        } else {
          coursesList = [];
        }

        return coursesList.map((json) {
          try {
            return Course.fromJson(json);
          } catch (e) {
            _logger.warning('Error parsing course: $e');
            _logger.warning('Course data: $json');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 500) {
        _logger.severe('Server error: ${response.body}');
        throw Exception('A server error occurred. Please try again later.');
      } else {
        _logger.warning('Failed to load saved courses: ${response.body}');
        throw Exception(
            'Failed to load saved courses. (${response.statusCode})');
      }
    } catch (e, stack) {
      _logger.severe('Error fetching user courses: $e\n$stack');
      throw Exception('Could not load saved courses. Please try again.');
    }
  }
}

// Widget for the Save Course Button (Bookmark icon)
class SaveCourseButton extends StatefulWidget {
  final String courseId;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final Function(bool)? onSaveChanged;
  final VoidCallback? onAuthRequired;

  const SaveCourseButton({
    super.key,
    required this.courseId,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.onSaveChanged,
    this.onAuthRequired,
  });

  @override
  State<SaveCourseButton> createState() => _SaveCourseButtonState();
}

class _SaveCourseButtonState extends State<SaveCourseButton> {
  final SavedCourseService _saveService = SavedCourseService();
  final AuthService _authService = AuthService();
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final isSaved = await _saveService.checkIfCourseSaved(widget.courseId);
      if (mounted) {
        setState(() {
          _isSaved = isSaved;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.warning('Error checking saved status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSaveCourse() async {
    try {
      setState(() => _isLoading = true);
      final isLoggedIn = await _authService.isLoggedIn();

      if (!mounted) return;

      if (!isLoggedIn) {
        if (widget.onAuthRequired != null) {
          widget.onAuthRequired!();
        }
        return;
      }

      if (_isSaved) {
        await _saveService.unsaveCourse(widget.courseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Course removed from your saved list'),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      } else {
        await _saveService.saveCourse(widget.courseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Course added to your saved list'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _isSaved = !_isSaved;
        _isLoading = false;
      });

      if (widget.onSaveChanged != null) {
        widget.onSaveChanged!(_isSaved);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: _isLoading
            ? SizedBox(
                width: widget.size ?? 24,
                height: widget.size ?? 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.activeColor ?? Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: _isSaved
                    ? (widget.activeColor ?? Colors.red)
                    : (widget.inactiveColor ?? Colors.white),
                size: widget.size ?? 24,
              ),
        onPressed: _isLoading ? null : _handleSaveCourse,
        tooltip: _isSaved ? 'Remove from saved courses' : 'Save course',
      ),
    );
  }
}

class CourseDetails extends StatefulWidget {
  final String courseId;

  const CourseDetails({super.key, required this.courseId});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Course? course;
  List<Module> modules = [];
  List<Lesson> lessons = [];
  bool isLoading = true;
  String errorMessage = '';
  int selectedModuleIndex = 0;
  bool _isSavingCourse = false;
  String? currentVideoUrl;
  bool isVideoInitialized = false;
  final CourseService _courseService = CourseService();
  final ModuleService _moduleService = ModuleService();
  final LessonService _lessonService = LessonService();
  final AuthService _authService = AuthService();
  final CourseSaveService _courseSaveService = CourseSaveService();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _loadCourseData() async {
    if (!mounted) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Load course details
      final courseData = await _courseService.getCourseById(widget.courseId);
      if (!mounted) {
        return;
      }

      // Load all lessons for the course at once
      final lessonsData =
          await _lessonService.getLessonsByCourse(widget.courseId);
      if (!mounted) {
        return;
      }

      // Load modules
      final modulesData =
          await _moduleService.getModulesByCourse(widget.courseId);
      if (!mounted) {
        return;
      }

      modulesData.sort((a, b) => a['order'].compareTo(b['order']));

      if (mounted) {
        setState(() {
          course = courseData;
          modules = modulesData.map((m) => Module.fromJson(m)).toList();
          lessons = lessonsData.map((l) => Lesson.fromJson(l)).toList();
          isLoading = false;
        });

        // If there are modules, show lessons for the first module
        if (modules.isNotEmpty) {
          _filterLessonsForModule(modules[0].id);
        }
      }
    } catch (e) {
      _logger.severe('Error loading course data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error loading course: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading course: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterLessonsForModule(String moduleId) {
    setState(() {
      selectedModuleIndex = 0;
    });
    // Lessons are already loaded, we just filter them
    final filteredLessons =
        lessons.where((l) => l.moduleId == moduleId).toList();
    filteredLessons.sort((a, b) => a.order.compareTo(b.order));

    setState(() {
      lessons = filteredLessons;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = Localizations.localeOf(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading course details...',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCourseData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (course == null) {
      return Scaffold(
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(
            'Course not found',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? Colors.grey[900] : Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: isDark
                ? Colors.grey[900]
                : Theme.of(context).appBarTheme.backgroundColor,
            flexibleSpace: Stack(
              children: [
                isVideoInitialized && _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ImageUtils.getImageWidget(
                          course!.thumbnail,
                          fit: BoxFit.cover,
                        ),
                      ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(128),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      course!.getLocalizedTitle(locale),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: SaveCourseButton(
                    courseId: widget.courseId,
                    activeColor: Colors.red,
                    inactiveColor: Colors.white,
                    size: 32,
                    onAuthRequired: () async {
                      await _authService.saveTargetRoute(
                          '/course_details/${widget.courseId}');
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseMetadata(isDark),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSavingCourse ? null : _startAndSaveCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSavingCourse
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_circle_filled,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Save Course & Start',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    labelColor: isDark
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                    unselectedLabelColor:
                        isDark ? Colors.grey[400] : Colors.grey[700],
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Content'),
                      Tab(text: 'About'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContentTab(locale, isDark),
                _buildAboutTab(locale, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseMetadata(bool isDark) {
    return Row(
      children: [
        Icon(Icons.access_time,
            size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 4),
        Text('${course!.duration} hours',
            style:
                TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(width: 16),
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          '${course!.rating.average.toStringAsFixed(1)} (${course!.rating.count})',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildContentTab(Locale locale, bool isDark) {
    return ListView.builder(
      itemCount: modules.length,
      itemBuilder: (context, moduleIndex) {
        final module = modules[moduleIndex];
        final moduleLessons = lessons
            .where((l) => l.moduleId == module.id)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            initiallyExpanded: moduleIndex == selectedModuleIndex,
            backgroundColor: isDark ? Colors.grey[850] : Colors.grey[100],
            collapsedBackgroundColor: isDark ? Colors.grey[900] : Colors.white,
            title: Text(
              module.getLocalizedTitle(locale.languageCode),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onExpansionChanged: (expanded) {
              if (expanded) {
                setState(() {
                  selectedModuleIndex = moduleIndex;
                });
              }
            },
            children: moduleLessons.isEmpty
                ? [
                    ListTile(
                      title: Text(
                        'No lessons available for this module',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    )
                  ]
                : moduleLessons.map((lesson) {
                    final hasVideo = lesson.content.videoUrl.isNotEmpty;
                    final lessonGlobalIndex = lessons.indexWhere((l) =>
                        l.id == lesson.id && l.moduleId == lesson.moduleId);

                    return ListTile(
                      leading: Icon(
                        hasVideo ? Icons.play_circle : Icons.article,
                        color: hasVideo
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? Colors.white : Colors.black54),
                      ),
                      title: Text(
                        lesson.getLocalizedTitle(locale),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${lesson.duration} min',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      trailing: hasVideo
                          ? Icon(
                              Icons.play_circle_outline,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => _onLessonTap(lessonGlobalIndex),
                    );
                  }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(Locale locale, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            course!.getLocalizedDescription(locale),
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Course Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.school,
            label: 'Level',
            value: course!.getLocalizedLevel(locale),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.language,
            label: 'Language',
            value: course!.getLocalizedLanguage(locale),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Instructor',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageUtils.getImageWidget(
                    course!.instructor.user.profilePicture,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${course!.instructor.user.firstNameEn} ${course!.instructor.user.lastNameEn}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course!.instructor.professionalTitleEn,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    if (course!.instructor.biographyEn.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'About Instructor',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course!.instructor.biographyEn,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (course!.instructor.socialMediaLinks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Social Media',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: course!.instructor.socialMediaLinks.entries
                            .map((entry) => IconButton(
                                  icon: Icon(
                                    _getSocialMediaIcon(entry.key),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () => _launchUrl(entry.value),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  IconData _getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return Icons.business;
      case 'twitter':
        return Icons.chat;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube':
        return Icons.play_circle;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching URL: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onLessonTap(int index) async {
    final lesson = lessons[index];
    final hasVideo = lesson.content.videoUrl.isNotEmpty;

    if (hasVideo) {
      // First check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Auto-save the course when opening a lesson
        if (mounted) {
          _startAndSaveCourse();
        }

        // User is logged in, navigate to the lesson viewer
        if (mounted) {
          Navigator.of(context).pushNamed(
            '/lessons_viewer',
            arguments: {
              'course': course,
              'modules': modules,
              'lessons': lessons,
              'initialIndex': index,
            },
          );
        }
      } else {
        // User is not logged in, save the target route and redirect to login
        if (mounted) {
          await _authService
              .saveTargetRoute('/course_details/${widget.courseId}');
          Navigator.pushNamed(context, '/login');
        }
      }
    }
  }

  Future<void> _startAndSaveCourse() async {
    final isLoggedIn = await _authService.isLoggedIn();

    if (!isLoggedIn) {
      // Save the current route and navigate to login
      await _authService.saveTargetRoute('/course_details/${widget.courseId}');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/login',
          arguments: {
            'showAlert': true,
            'alertMessage': 'Please login to start this course',
          },
        );
      }
      return;
    }

    setState(() {
      _isSavingCourse = true;
    });

    try {
      // Check if course is already saved
      final isSaved =
          await _courseSaveService.checkIfCourseSaved(widget.courseId);

      // Only save if not already saved
      if (!isSaved) {
        await _courseSaveService.saveCourse(widget.courseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course saved to your library!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // Navigate to the first lesson if available
      if (lessons.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pushNamed(
            '/lessons_viewer',
            arguments: {
              'course': course,
              'modules': modules,
              'lessons': lessons,
              'initialIndex': 0,
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No lessons available for this course'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      _logger.severe('Error starting course: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting course: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingCourse = false;
        });
      }
    }
  }

  Color _getBackgroundColor() {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.8)
        : Theme.of(context).colorScheme.surface.withValues(alpha: 0.9);
  }
}
