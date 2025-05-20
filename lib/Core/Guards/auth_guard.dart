import 'package:almentor_clone/pages/auth/loginPage.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final AuthService _authService = AuthService();
  final bool requiresAuth;
  final String? targetRoute;

  AuthGuard({
    super.key,
    required this.child,
    this.requiresAuth = false,
    this.targetRoute,
  });

  @override
  Widget build(BuildContext context) {
    if (!requiresAuth) return child;

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
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (targetRoute != null) {
              await _authService.saveTargetRoute(targetRoute!);
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => LoginPage(
                  showAlert: true,
                  alertMessage: 'Please login to access this content',
                ),
              ),
            );
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return child;
      },
    );
  }
}
