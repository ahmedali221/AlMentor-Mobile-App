import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../Core/Constants/apiConstants.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user';
  static const String _targetRouteKey = 'target_route';

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        final token = responseData['token'];
        final userId = responseData['user']['_id'];

        await _saveAuthData(token, userId);

        // Fetch full user data immediately after login
        final fullUser = await fetchUserData(userId, token);

        if (fullUser != null) {
          return {
            'success': true,
            'user': fullUser,
            'message': responseData['message'] ?? 'Login successful',
          };
        } else {
          return {
            'success': false,
            'message': 'Login successful, but failed to fetch user details.',
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        final token = responseData['token'];
        final userData = responseData['user'];
        await _saveAuthData(token, userData);
        return {
          'success': true,
          'user': User.fromJson(userData),
          'message': responseData['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserData = prefs.getString(_userKey);

    if (savedUserData != null) {
      return User.fromJson(json.decode(savedUserData));
    }

    final token = prefs.getString(_tokenKey);
    final userId = prefs.getString('user_id');

    if (token != null && userId != null) {
      return await fetchUserData(userId, token);
    }

    return null;
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save target route for redirect after login
  Future<void> saveTargetRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_targetRouteKey, route);
  }

  // Get target route
  Future<String?> getTargetRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_targetRouteKey);
  }

  // Clear target route
  Future<void> clearTargetRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_targetRouteKey);
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Save authentication data
  Future<void> _saveAuthData(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString('user_id', userId);
  }

  // Fetch user data by ID
  Future<User?> fetchUserData(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(userData));
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
