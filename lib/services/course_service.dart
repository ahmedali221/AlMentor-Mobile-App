import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../Core/Constants/apiConstants.dart';

class CourseService {
  // Get all courses
  Future<List<Course>> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/courses'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = json.decode(response.body);
        return coursesJson.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching courses: $e");
      throw Exception('Failed to load courses: $e');
    }
  }

  // Get course by ID
  Future<Course> getCourseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/courses/$id'),
      );

      if (response.statusCode == 200) {
        print('courseResponse runtimeType: ${response.runtimeType}');
        print('courseResponse body: ${response.body}');
        return Course.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load course: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load course: $e');
    }
  }

  // Get courses by category
  Future<List<Course>> getCoursesByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/courses/category/$categoryId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = json.decode(response.body);
        return coursesJson.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load category courses: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching category courses: $e");
      throw Exception('Failed to load category courses: $e');
    }
  }

  // Get courses by instructor
  Future<List<Course>> getCoursesByInstructor(String instructorId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/courses/instructor/$instructorId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = json.decode(response.body);
        return coursesJson.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load instructor courses: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching instructor courses: $e");
      throw Exception('Failed to load instructor courses: $e');
    }
  }
}
