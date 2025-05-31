import 'dart:convert';
import 'package:http/http.dart' as http;

class LessonService {
  // Get lessons by module ID
  Future<List<dynamic>> getLessonsByModule(String moduleId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://al-mentor-database-production.up.railway.app/api/lessons/module/$moduleId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> lessonsJson = json.decode(response.body);
        return lessonsJson;
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching lessons: $e");
      // Return empty list for now
      return [];
    }
  }

  // Get lessons by course ID
  Future<List<dynamic>> getLessonsByCourse(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://al-mentor-database-production.up.railway.app/api/lessons/course/$courseId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> lessonsJson = json.decode(response.body);
        return lessonsJson;
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching lessons: $e");
      // Return empty list for now
      return [];
    }
  }

  // Get lesson by ID
  Future<dynamic> getLessonById(String id) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://al-mentor-database-production.up.railway.app/api/lessons/$id'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load lesson: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching lesson: $e");
      // Return empty object for now
      return {};
    }
  }
}
