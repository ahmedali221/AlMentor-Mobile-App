import 'package:flutter/material.dart';
import '../../services/subscription_service.dart';
import '../../services/auth_service.dart';

class SubscriptionGuard {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final AuthService _authService = AuthService();

  // Check if user can access premium content
  Future<bool> canAccessPremiumContent() async {
    // First check if user is logged in
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      return false;
    }

    // Then check if user has an active subscription
    return await _subscriptionService.hasActiveSubscription();
  }

  // Handle subscription check and redirect if needed
  Future<bool> handleSubscriptionCheck(BuildContext context,
      {String? redirectRoute}) async {
    final isLoggedIn = await _authService.isLoggedIn();

    if (!isLoggedIn) {
      // Save the current route and navigate to login
      if (redirectRoute != null) {
        await _authService.saveTargetRoute(redirectRoute);
      }

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/login',
          arguments: {
            'showAlert': true,
            'alertMessage': 'Please login to access this content',
          },
        );
      }
      return false;
    }

    final hasSubscription = await _subscriptionService.hasActiveSubscription();

    if (!hasSubscription) {
      if (context.mounted) {
        // Show subscription required dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Subscription Required'),
            content: const Text(
              'You need an active subscription to access this content. Would you like to subscribe now?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/subscribe');
                },
                child: const Text('Subscribe'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    return true;
  }
}
