import 'dart:convert';
import 'package:http/http.dart' as http;

class ModuleService {
  // Get modules by course ID
  Future<List<dynamic>> getModulesByCourse(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://al-mentor-database-production.up.railway.app/api/modules/course/$courseId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> modulesJson = json.decode(response.body);
        return modulesJson;
      } else {
        throw Exception('Failed to load modules: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching modules: $e");
      // Return empty list for now
      return [];
    }
  }

  // Get module by ID
  Future<dynamic> getModuleById(String id) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://al-mentor-database-production.up.railway.app/api/modules/$id'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load module: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching module: $e");
      // Return empty object for now
      return {};
    }
  }
}
