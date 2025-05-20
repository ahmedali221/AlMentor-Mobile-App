import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Core/Custom Widgets/customButton.dart';
import '../../Core/Custom Widgets/customTextField.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../Core/Localization/app_translations.dart';
import '../../Core/Providers/language_provider.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginPage({super.key});
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
          final userId = responseData['user']?['_id'];

          if (token != null) {
            // Use debugPrint instead of print for logging
            debugPrint('Token: $token');
            debugPrint('User : $userData');
            debugPrint('User ID: $userId');

            final prefs = await SharedPreferences.getInstance();
            prefs.setString('jwt_token', token);
            prefs.setString('user', json.encode(userData));
            prefs.setString('user_id', userId.toString());

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
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = languageProvider.currentLocale.languageCode;
    final isRtl = languageProvider.isArabic;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: Stack(
        children: [
          // Background Design
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment:
                      isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Logo and Welcome Text
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.jpeg',
                            height: 60,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppTranslations.getText('welcome_back', locale),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppTranslations.getText('login_subtitle', locale),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login Form Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: isRtl
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTranslations.getText(
                                    'login_to_account', locale),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomTextField(
                                labelText:
                                    AppTranslations.getText('email', locale),
                                hintText: AppTranslations.getText(
                                    'email_hint', locale),
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: isRtl
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                prefixIcon: Icon(Icons.email,
                                    color: Theme.of(context).primaryColor),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                labelText:
                                    AppTranslations.getText('password', locale),
                                hintText: AppTranslations.getText(
                                    'password_hint', locale),
                                controller: passwordController,
                                obscureText: true,
                                textDirection: isRtl
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                prefixIcon: Icon(Icons.lock,
                                    color: Theme.of(context).primaryColor),
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                text: AppTranslations.getText('login', locale),
                                onPressed: () => loginUser(context),
                                backgroundColor: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                width: double.infinity,
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign Up Link
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signup'),
                        child: Text.rich(
                          TextSpan(
                            text: AppTranslations.getText('no_account', locale),
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            children: [
                              TextSpan(
                                text:
                                    AppTranslations.getText('sign_up', locale),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
