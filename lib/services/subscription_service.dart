import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_record.dart';
import '../Core/Constants/apiConstants.dart';
import 'auth_service.dart';
import 'package:logging/logging.dart';

class SubscriptionService {
  final String baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();
  final _logger = Logger('SubscriptionService');

  // Get auth token from shared preferences
  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  // Get user ID from shared preferences
  Future<String?> _getUserId() async {
    final user = await _authService.getCurrentUser();
    return user?.id;
  }

  // Check if user has an active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId == null || token == null) {
        return false; // User not authenticated
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user-subscriptions/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.info('Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if there's at least one active subscription
        if (data is List && data.isNotEmpty) {
          return data.any((sub) =>
              sub['status'] == 'active' ||
              sub['status']['en'] == 'active' ||
              sub['status'] == 'نشط' ||
              sub['status']['ar'] == 'نشط');
        } else if (data is Map &&
            data['data'] is List &&
            data['data'].isNotEmpty) {
          return data['data'].any((sub) =>
              sub['status'] == 'active' ||
              sub['status']['en'] == 'active' ||
              sub['status'] == 'نشط' ||
              sub['status']['ar'] == 'نشط');
        }
        return false;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        _logger
            .warning('Failed to check subscription status: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.severe('Could not check subscription status: $e');
      return false;
    }
  }

  // Get user's subscription details
  Future<List<SubscriptionRecord>> getUserSubscriptions() async {
    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId == null || token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user-subscriptions/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.info('Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        _logger.info('User subscriptions response: $responseData');

        List<dynamic> subscriptionsList;
        if (responseData is List) {
          subscriptionsList = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          subscriptionsList = responseData['data'];
        } else {
          subscriptionsList = [];
        }

        return subscriptionsList.map((json) {
          try {
            return SubscriptionRecord.fromJson(json);
          } catch (e) {
            _logger.warning('Error parsing subscription: $e');
            _logger.warning('Subscription data: $json');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please log in again.');
      } else {
        _logger.warning('Failed to load user subscriptions: ${response.body}');
        throw Exception(
            'Failed to load user subscriptions. (${response.statusCode})');
      }
    } catch (e) {
      _logger.severe('Error fetching user subscriptions: $e');
      throw Exception('Could not load user subscriptions. Please try again.');
    }
  }
}
