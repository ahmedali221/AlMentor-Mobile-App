import 'package:almentor_clone/Core/Custom%20Widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Core/Custom Widgets/customButton.dart';

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
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
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
        // Extract JWT token from response
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        if (token != null) {
          // Save token to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          Navigator.pushReplacementNamed(context, '/home');
          print('User signed up successfully');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup failed: Token not found')),
          );
        }
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
            spacing: 20,
            children: [
              const SizedBox(height: 20),
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
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000), // black text
                        ),
                      ),
                      CustomTextField(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        controller: usernameController,
                        prefixIcon:
                            const Icon(Icons.person, color: Color(0xFFeb2027)),
                      ),
                      CustomTextField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon:
                            const Icon(Icons.email, color: Color(0xFFeb2027)),
                      ),
                      CustomTextField(
                        labelText: 'Password',
                        hintText: 'Enter your Password',
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        prefixIcon:
                            const Icon(Icons.lock, color: Color(0xFFeb2027)),
                      ),
                      CustomTextField(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        controller: firstNameController,
                        prefixIcon: const Icon(Icons.person_outline,
                            color: Color(0xFFeb2027)),
                      ),
                      CustomTextField(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                        controller: lastNameController,
                        prefixIcon: const Icon(Icons.person_outline,
                            color: Color(0xFFeb2027)),
                      ),
                      CustomTextField(
                        labelText: 'Profile Picture URL',
                        hintText: 'Enter your profile picture URL',
                        controller: profilePictureController,
                        keyboardType: TextInputType.url,
                        prefixIcon:
                            const Icon(Icons.image, color: Color(0xFFeb2027)),
                      ),
                      CustomButton(
                        text: 'Sign Up',
                        onPressed: () => signUpUser(context),
                        backgroundColor: const Color(0xFFeb2027),
                        textColor: Colors.white,
                      ),
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
