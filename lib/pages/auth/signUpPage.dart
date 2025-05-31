import 'package:almentor_clone/Core/Custom%20Widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Custom Widgets/customButton.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../services/auth_service.dart';

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

  SignUpPage({super.key});

  Future<void> signUpUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.register(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (result['success'] == true) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
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
            spacing: 20,
            children: [
              const SizedBox(height: 20),
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
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      CustomTextField(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        controller: usernameController,
                        prefixIcon: Icon(Icons.person,
                            color: Theme.of(context).primaryColor),
                      ),
                      CustomTextField(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(Icons.email,
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
                      ),
                      CustomTextField(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        controller: firstNameController,
                        prefixIcon: Icon(Icons.person_outline,
                            color: Theme.of(context).primaryColor),
                      ),
                      CustomTextField(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                        controller: lastNameController,
                        prefixIcon: Icon(Icons.person_outline,
                            color: Theme.of(context).primaryColor),
                      ),
                      CustomTextField(
                        labelText: 'Profile Picture URL',
                        hintText: 'Enter URL to your profile picture',
                        controller: profilePictureController,
                        prefixIcon: Icon(Icons.image,
                            color: Theme.of(context).primaryColor),
                      ),
                      CustomButton(
                        text: 'Sign Up',
                        onPressed: () => signUpUser(context),
                        backgroundColor: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          "Already have an account? Login",
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
