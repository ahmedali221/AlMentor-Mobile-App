import 'dart:convert';
import 'package:almentor_clone/models/userSavedCourses.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../Core/Constants/apiConstants.dart';
import 'package:logging/logging.dart';

final _logger = Logger('SavedCourseService');

class SavedCourseService {
  final String baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();
  List<UserSavedCourse>? _cachedSavedCourses;
  DateTime? _lastFetch;

  // Get auth token from shared preferences
  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  // Get user ID from shared preferences
  Future<String?> _getUserId() async {
    final user = await _authService.getCurrentUser();
    return user?.id;
  }

  // Get all saved courses using the UserSavedCourse model
  Future<List<UserSavedCourse>> getUserSavedCourses(
      {bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh && _cachedSavedCourses != null && _lastFetch != null) {
        final cacheAge = DateTime.now().difference(_lastFetch!);
        if (cacheAge.inMinutes < 5) {
          // Cache for 5 minutes
          _logger.info('Returning cached saved courses');
          return _cachedSavedCourses!;
        }
      }

      print('Fetching saved courses...');
      final token = await _getToken();
      final userId = await _getUserId();

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      _logger.info('Fetching saved courses for user: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/saved-courses/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Received saved courses response');
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        // Parse the response as a List directly
        final List<dynamic> savedCoursesData = json.decode(response.body);
        _logger.info('Found ${savedCoursesData.length} saved courses');

        if (savedCoursesData.isEmpty) {
          _cachedSavedCourses = [];
          _lastFetch = DateTime.now();
          return [];
        }

        final List<UserSavedCourse> savedCourses = [];

        for (var savedCourseData in savedCoursesData) {
          try {
            final savedCourse = UserSavedCourse.fromJson(savedCourseData);
            savedCourses.add(savedCourse);
          } catch (e, stackTrace) {
            _logger.warning('Error parsing saved course: $e');
            _logger.warning('Stack trace: $stackTrace');
            _logger.warning('Saved course data: $savedCourseData');
            // Continue to next saved course
          }
        }

        // Update cache
        _cachedSavedCourses = savedCourses;
        _lastFetch = DateTime.now();
        _logger
            .info('Successfully parsed ${savedCourses.length} saved courses');

        return savedCourses;
      } else if (response.statusCode == 401) {
        _logger.warning('Authentication error: ${response.statusCode}');
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        _logger.warning('API error: ${response.statusCode}, ${response.body}');
        throw Exception(
            'Failed to load saved courses (${response.statusCode})');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error loading saved courses: $e');
      _logger.severe('Stack trace: $stackTrace');
      throw Exception('Could not load saved courses: $e');
    }
  }

  // Get all saved courses (backward compatibility)
  Future<List<Map<String, dynamic>>> getSavedCourses(
      {bool forceRefresh = false}) async {
    final savedCourses = await getUserSavedCourses(forceRefresh: forceRefresh);
    // returns only the course object (the map) for each saved course
    return savedCourses.map((sc) => sc.course).toList();
  }

  // Check if a course is saved by the current user
  Future<bool> checkIfCourseSaved(String courseId) async {
    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId == null || token == null) {
        return false; // User not authenticated
      }

      // Check cache first
      if (_cachedSavedCourses != null) {
        final isInCache = _cachedSavedCourses!.any((savedCourse) =>
            savedCourse.course['_id'] == courseId ||
            savedCourse.course['id'] == courseId);
        if (isInCache) return true;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/saved-courses/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> savedCoursesData = json.decode(response.body);

        return savedCoursesData.any((savedCourse) {
          final courseData = savedCourse['courseId'];
          if (courseData == null) return false;

          // Check both _id and id fields in the courseId object
          return courseData['_id'] == courseId || courseData['id'] == courseId;
        });
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        _logger.warning('Failed to check saved status: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.severe('Could not check saved status: $e');
      return false;
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
        Uri.parse('$baseUrl/saved-courses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'userId': userId, 'courseId': courseId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Invalidate cache after successful save
        _cachedSavedCourses = null;
        _lastFetch = null;
        return true;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
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
        Uri.parse('$baseUrl/saved-courses/$userId/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Remove from cache if it exists
        if (_cachedSavedCourses != null) {
          _cachedSavedCourses!.removeWhere(
            (savedCourse) =>
                savedCourse.course['_id'] == courseId ||
                savedCourse.course['id'] == courseId,
          );
        }
        return true;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        _logger.warning('Failed to unsave course: ${response.body}');
        throw Exception('Failed to unsave course. (${response.statusCode})');
      }
    } catch (e) {
      _logger.severe('Could not unsave course: $e');
      throw Exception('Could not unsave course. Please try again.');
    }
  }

  // Get saved course by course ID
  Future<UserSavedCourse?> getSavedCourseById(String courseId) async {
    final savedCourses = await getUserSavedCourses();
    try {
      return savedCourses.firstWhere(
          (sc) => sc.course['_id'] == courseId || sc.course['id'] == courseId);
    } catch (e) {
      return null;
    }
  }

  // Clear cache manually
  void clearCache() {
    _cachedSavedCourses = null;
    _lastFetch = null;
  }

  // Get cached saved courses count
  int get cachedSavedCoursesCount => _cachedSavedCourses?.length ?? 0;
}
