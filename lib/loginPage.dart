import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'customTextField.dart';
import 'customButton.dart';

class Loginpage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<void> loginUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Your token
      const String token =
          '0af59917a88f7317135c0e73fede9a442c4a4b6f1bcbb6f5ddf19b72614648a3';

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful login
        Navigator.pushReplacementNamed(context, '/home');
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
            children: [
              const SizedBox(height: 40),
              // Logo
              Image.asset(
                'assets/almentor_logo.png',
                height: 80,
              ),
              const SizedBox(height: 20),
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
                    children: <Widget>[
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000), // black text
                        ),
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Login',
                        onPressed: () => loginUser(context),
                        backgroundColor: const Color(0xFFeb2027),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
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
