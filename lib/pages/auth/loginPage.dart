import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../Core/Custom Widgets/customButton.dart';
import '../../Core/Custom Widgets/customTextField.dart';

class Loginpage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<void> loginUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
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
        if (token != null) {
          print('Token: $token');
          // Save token to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: Token not found')),
          );
        }
      } else {
        // Handle login error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // white background
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
              // Card Container
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000), // black text
                        ),
                      ),
                      CustomTextField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon:
                            const Icon(Icons.email, color: Color(0xFFeb2027)),
                        suffixIcon: const Icon(Icons.check_circle,
                            color: Color(0xFFeb2027)),
                      ),
                      CustomTextField(
                        labelText: 'Password',
                        hintText: 'Enter your Password',
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        prefixIcon:
                            const Icon(Icons.lock, color: Color(0xFFeb2027)),
                        suffixIcon: const Icon(Icons.check_circle,
                            color: Color(0xFFeb2027)),
                      ),
                      CustomButton(
                        text: 'Login',
                        onPressed: () => loginUser(context),
                        backgroundColor: const Color(0xFFeb2027),
                        textColor: Colors.white,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(color: Color(0xFFeb2027)),
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
