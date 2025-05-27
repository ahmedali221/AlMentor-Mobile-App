// saved_course_service.dart
import 'dart:convert';
import 'package:almentor_clone/models/user.dart';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../models/instructor.dart';
import '../services/auth_service.dart';
import '../Core/Constants/apiConstants.dart';
import 'package:logging/logging.dart';

final _logger = Logger('SavedCourseService');

class SavedCourseService {
  final String baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();
  List<Course>? _cachedCourses;
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

  // Get all saved courses with caching
  Future<List<Course>> getSavedCourses({bool forceRefresh = false}) async {
    try {
      // Check cache if not forcing refresh
      if (!forceRefresh &&
          _cachedCourses != null &&
          _lastFetch != null &&
          DateTime.now().difference(_lastFetch!).inMinutes < 5) {
        _logger.info('Returning cached saved courses');
        return _cachedCourses!;
      }

      final token = await _getToken();
      final userId = await _getUserId();

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      _logger.info('Fetching saved courses for user: $userId');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/saved-courses/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _logger.info('Received saved courses response');
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check if the response contains the savedCourses field
        if (!responseData.containsKey('savedCourses')) {
          _logger.warning(
              'Response does not contain savedCourses field: $responseData');
          throw Exception(
              'Invalid response format: missing savedCourses field');
        }

        final List<dynamic> savedCoursesData = responseData['savedCourses'];
        _logger.info('Found ${savedCoursesData.length} saved courses');

        if (savedCoursesData.isEmpty) {
          _cachedCourses = [];
          _lastFetch = DateTime.now();
          return [];
        }

        final List<Course> courses = [];

        for (var courseData in savedCoursesData) {
          try {
            // Extract course data, preferring the nested 'course' object if available
            final Map<String, dynamic> courseDetails =
                courseData['course'] ?? courseData;

            // Create a complete course object with all required fields
            final course = Course(
              id: courseDetails['_id'] ?? courseDetails['id'] ?? '',
              title: _extractMapStringString(courseDetails['title']),
              slug: _extractMapStringString(
                  courseDetails['slug'] ?? {'en': '', 'ar': ''}),
              description: _extractMapStringString(
                  courseDetails['description'] ?? {'en': '', 'ar': ''}),
              shortDescription: courseDetails['shortDescription'] != null
                  ? _extractMapStringString(courseDetails['shortDescription'])
                  : null,
              level: _extractMapStringString(courseDetails['level']),
              language: _extractMapStringString(courseDetails['language']),
              thumbnail: courseDetails['thumbnail']?.toString().trim() ?? '',
              duration: _extractInt(courseDetails['duration']),
              enrollmentCount:
                  _extractInt(courseDetails['enrollmentCount'] ?? 0),
              isFree: courseDetails['isFree'] ?? false,
              rating: Rating.fromJson(
                  courseDetails['rating'] ?? {'average': 0, 'count': 0}),
              lastUpdated: DateTime
                  .now(), // Default as this might not be in the saved course data
              topicId: courseDetails['topic']?['_id'] ?? '',
              subtopicId: courseDetails['subtopic']?['_id'],
              categoryId: courseDetails['category']?['_id'] ?? '',
              modules: [], // These might not be included in the saved course data
              freeLessons: [], // These might not be included in the saved course data
              instructor: _extractInstructor(courseDetails['instructor']),
            );

            courses.add(course);
          } catch (e, stackTrace) {
            _logger.warning('Error parsing course: $e');
            _logger.warning('Stack trace: $stackTrace');
            _logger.warning('Course data: $courseData');
            // Continue to next course instead of failing the entire request
          }
        }

        // Update cache
        _cachedCourses = courses;
        _lastFetch = DateTime.now();
        _logger.info('Successfully parsed ${courses.length} courses');

        return courses;
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

  // Helper method to extract Map<String, String> from dynamic JSON
  Map<String, String> _extractMapStringString(dynamic data) {
    if (data == null) return {'en': '', 'ar': ''};

    if (data is Map) {
      return Map<String, String>.from(
          data.map((key, value) => MapEntry(key.toString(), value.toString())));
    }

    return {'en': data.toString(), 'ar': data.toString()};
  }

  // Helper method to extract integer values
  int _extractInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  // Helper method to extract instructor data
  Instructor _extractInstructor(dynamic instructorData) {
    if (instructorData == null) {
      return Instructor(
        id: '',
        professionalTitleEn: '',
        professionalTitleAr: '',
        expertiseEn: [],
        expertiseAr: [],
        biographyEn: '',
        biographyAr: '',
        yearsOfExperience: 0,
        approvalStatus: '',
        user: User.fromJson({}),
        socialMediaLinks: {},
      );
    }

    try {
      List<String> expertiseEn = [];
      List<String> expertiseAr = [];

      if (instructorData['expertiseAreas'] != null) {
        if (instructorData['expertiseAreas']['en'] is List) {
          expertiseEn =
              List<String>.from(instructorData['expertiseAreas']['en']);
        }
        if (instructorData['expertiseAreas']['ar'] is List) {
          expertiseAr =
              List<String>.from(instructorData['expertiseAreas']['ar']);
        }
      }

      return Instructor(
        id: instructorData['_id'] ?? instructorData['id'] ?? '',
        professionalTitleEn: instructorData['professionalTitle']?['en'] ?? '',
        professionalTitleAr: instructorData['professionalTitle']?['ar'] ?? '',
        expertiseEn: expertiseEn,
        expertiseAr: expertiseAr,
        biographyEn: instructorData['biography']?['en'] ?? '',
        biographyAr: instructorData['biography']?['ar'] ?? '',
        yearsOfExperience: instructorData['yearsOfExperience'] ?? 0,
        approvalStatus: instructorData['approvalStatus'] ?? '',
        user: User.fromJson(
            instructorData['user'] ?? instructorData['profile'] ?? {}),
        socialMediaLinks:
            Map<String, String>.from(instructorData['socialMediaLinks'] ?? {}),
      );
    } catch (e) {
      _logger.warning('Error parsing instructor: $e');
      return Instructor(
        id: instructorData['_id'] ?? instructorData['id'] ?? '',
        professionalTitleEn: '',
        professionalTitleAr: '',
        expertiseEn: [],
        expertiseAr: [],
        biographyEn: '',
        biographyAr: '',
        yearsOfExperience: 0,
        approvalStatus: '',
        user: User.fromJson(instructorData['user'] ?? {}),
        socialMediaLinks: {},
      );
    }
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the response contains savedCourses field
        if (data is Map && data.containsKey('savedCourses')) {
          final savedCourses = data['savedCourses'] as List;
          return savedCourses.any((course) =>
              (course['id'] == courseId || course['_id'] == courseId) ||
              (course['course'] != null &&
                  (course['course']['id'] == courseId ||
                      course['course']['_id'] == courseId)));
        }

        return false;
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
        Uri.parse('$baseUrl/api/saved-courses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'userId': userId, 'courseId': courseId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Invalidate cache after successful save
        _cachedCourses = null;
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
        Uri.parse('$baseUrl/api/saved-courses/$userId/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Invalidate cache after successful unsave
        _cachedCourses = null;
        _lastFetch = null;
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
}
