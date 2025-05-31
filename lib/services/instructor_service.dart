import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/instructor.dart';
import '../Core/Constants/apiConstants.dart';

class InstructorService {
  // Get all instructors
  Future<List<Instructor>> getInstructors() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/instructors'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> instructorsJson = json.decode(response.body);
        return instructorsJson
            .map((json) => Instructor.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load instructors: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching instructors: $e");
      // Return demo data for now
      throw Exception('Failed to load course: $e');
    }
  }

  // Get instructor by ID
  Future<Instructor> getInstructorById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/instructors/$id'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Extract the instructor data from the 'data' field
        return Instructor.fromJson(responseData['data']);
      } else {
        throw Exception('Failed to load instructor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load instructor: $e');
    }
  }
}
