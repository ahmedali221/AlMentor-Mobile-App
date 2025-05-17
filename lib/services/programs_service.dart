// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/program.dart';
// import '../Core/Constants/apiConstants.dart';

// class ProgramService {
//   Future<List<Program>> fetchPrograms() async {
//     try {
//       final response = await http.get(Uri.parse(
//         'http://192.168.1.7:5000/api/programs',
//       ));
//       if (response.statusCode == 200) {
//         List<dynamic> jsonData = json.decode(response.body);
//         return jsonData.map((program) => Program.fromJson(program)).toList();
//       } else {
//         throw Exception('Failed to load programs');
//       }
//     } catch (e) {
//       throw Exception('Failed to load programs: $e');
//     }
//   }
// }
