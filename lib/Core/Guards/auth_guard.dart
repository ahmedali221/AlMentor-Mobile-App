import 'package:almentor_clone/pages/auth/loginPage.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final AuthService authService;
  final String currentRoute;

  AuthGuard({
    Key? key,
    required this.child,
    required this.currentRoute,
    AuthService? authService,
  })  : authService = authService ?? AuthService(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAuthenticated = snapshot.data ?? false;

        if (!isAuthenticated) {
          // Redirect to login page after the widget is built
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await authService.saveTargetRoute(currentRoute);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => LoginPage(
                  showAlert: true,
                  alertMessage: 'Please login to access this content',
                ),
              ),
            );
          });
          // Show loading indicator while redirecting
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is authenticated, show the protected content
        return child;
      },
    );
  }
}
