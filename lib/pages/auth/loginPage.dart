import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Core/Custom Widgets/customButton.dart';
import '../../Core/Custom Widgets/customTextField.dart';
import '../../Core/Providers/themeProvider.dart';

class Loginpage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Loginpage({super.key});
  Future<void> loginUser(BuildContext context) async {
    bool mounted = true;
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/auth/login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': emailController.text,
            'password': passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          // Extract JWT token from response
          final responseData = json.decode(response.body);
          final token = responseData['token'];
          final userData = responseData['user'];

          if (token != null) {
            // Use debugPrint instead of print for logging
            debugPrint('Token: $token');
            debugPrint('User : $userData');

            final prefs = await SharedPreferences.getInstance();
            prefs.setString('jwt_token', token);
            prefs.setString('user', json.encode(userData));
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login failed: Token not found')),
              );
            }
          }
        } else {
          // Handle login error
          String errorMsg = 'Login failed: ';
          try {
            final errorData = json.decode(response.body);
            errorMsg += errorData['message'] ?? response.body;
          } catch (_) {
            errorMsg += response.body;
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            spacing: 24,
            children: [
              // Logo
              Image.asset(
                'assets/almentor_logo.png',
                height: 80,
              ),

              // Theme toggle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
              ),

              // Card Container
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 24,
                    children: <Widget>[
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      CustomTextField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.email,
                            color: Theme.of(context).primaryColor),
                        suffixIcon: Icon(Icons.check_circle,
                            color: Theme.of(context).primaryColor),
                      ),
                      CustomTextField(
                        labelText: 'Password',
                        hintText: 'Enter your Password',
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        prefixIcon: Icon(Icons.lock,
                            color: Theme.of(context).primaryColor),
                        suffixIcon: Icon(Icons.check_circle,
                            color: Theme.of(context).primaryColor),
                      ),
                      CustomButton(
                        text: 'Login',
                        onPressed: () => loginUser(context),
                        backgroundColor: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          "Don't have an account? Sign Up",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
