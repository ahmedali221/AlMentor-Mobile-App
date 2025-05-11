import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'customTextField.dart';
import 'customButton.dart';

class SignUpPage extends StatelessWidget {
  final usernameController = TextEditingController(text: "sara456");
  final emailController = TextEditingController(text: "sara@example.com");
  final passwordController = TextEditingController(
      text: "\$2b\$12\$anFoizvxVtxD1HJ934Ci3e5y87FAnYoJ0VIVKoq6oTIxgkjrKf2We");
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final profilePictureController =
      TextEditingController(text: "https://example.com/profiles/sara.jpg");
  final _formKey = GlobalKey<FormState>();

  Future<void> signUpUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      const String token =
          '0af59917a88f7317135c0e73fede9a442c4a4b6f1bcbb6f5ddf19b72614648a3'; // Your hardcoded token

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode({
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'profilePicture': profilePictureController.text,
        }),
      );

      if (response.statusCode == 201) {
        // Handle successful signup
        Navigator.pushReplacementNamed(context, '/home');
        print('User signed up successfully');
      } else {
        // Handle signup error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${response.body}')),
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
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000), // black text
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        controller: usernameController,
                        prefixIcon:
                            const Icon(Icons.person, color: Color(0xFFeb2027)),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon:
                            const Icon(Icons.email, color: Color(0xFFeb2027)),
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
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        controller: firstNameController,
                        prefixIcon: const Icon(Icons.person_outline,
                            color: Color(0xFFeb2027)),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                        controller: lastNameController,
                        prefixIcon: const Icon(Icons.person_outline,
                            color: Color(0xFFeb2027)),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Profile Picture URL',
                        hintText: 'Enter your profile picture URL',
                        controller: profilePictureController,
                        keyboardType: TextInputType.url,
                        prefixIcon:
                            const Icon(Icons.image, color: Color(0xFFeb2027)),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Sign Up',
                        onPressed: () => signUpUser(context),
                        backgroundColor: const Color(0xFFeb2027),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Already have an account? Login",
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
