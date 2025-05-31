import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_chat.dart';
import '../Core/Constants/apiConstants.dart';
import 'auth_service.dart';

class ChatService {
  final String baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();

  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  Future<String?> _getUserId() async {
    final user = await _authService.getCurrentUser();
    return user?.id;
  }

  Future<List<dynamic>> getUserChats() async {
    final userId = await _getUserId();
    final token = await _getToken();
    if (userId == null || token == null) {
      throw Exception('User not authenticated');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/chats/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load chats');
    }
  }

  Future<Map<String, dynamic>> getChatById(String chatId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/chats/$chatId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load chat');
    }
  }

  Future<Map<String, dynamic>> saveChat(
      {String? chatId, required String message, String role = 'user'}) async {
    final userId = await _getUserId();
    final token = await _getToken();
    if (userId == null || token == null) {
      throw Exception('User not authenticated');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/chats/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'userId': userId,
        if (chatId != null) 'chatId': chatId,
        'message': message,
        'role': role,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to save chat');
    }
  }

  Future<void> deleteChat(String chatId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    final response = await http.delete(
      Uri.parse('$baseUrl/chats/$chatId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete chat');
    }
  }

  Future<void> updateChatTitle(String chatId, String title) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    final response = await http.put(
      Uri.parse('$baseUrl/chats/$chatId/title'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'title': title}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update chat title');
    }
  }
}
