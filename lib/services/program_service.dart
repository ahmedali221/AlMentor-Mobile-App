import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/program.dart';
import '../Core/Constants/apiConstants.dart';

class ProgramService {
  // Get all programs
  Future<List<Program>> getPrograms() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/programs'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> programsJson = json.decode(response.body);
        return programsJson.map((json) => Program.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load programs: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching programs: $e");
      // Return demo data for now
      return Program.getDemoPrograms();
    }
  }

  // Get program by ID
  Future<Program> getProgramById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/programs/$id'),
      );

      if (response.statusCode == 200) {
        return Program.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load program: ${response.statusCode}');
      }
    } catch (e) {
      // Return a demo program for now
      return Program.getDemoPrograms().first;
    }
  }
}
