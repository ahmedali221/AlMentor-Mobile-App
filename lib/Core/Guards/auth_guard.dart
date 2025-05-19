import 'package:almentor_clone/pages/auth/loginPage.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final AuthService _authService = AuthService();

  AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAuthenticated = snapshot.data ?? false;
        if (!isAuthenticated) {
          return Loginpage();
        }

        return child;
      },
    );
  }
}
