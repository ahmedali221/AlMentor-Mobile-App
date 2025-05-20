import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../Core/Custom Widgets/customButton.dart';
import '../../Core/Custom Widgets/customTextField.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../Core/Localization/app_translations.dart';
import '../../Core/Providers/language_provider.dart';

class LoginPage extends StatefulWidget {
  final bool showAlert;
  final String? alertMessage;

  const LoginPage({
    super.key,
    this.showAlert = false,
    this.alertMessage,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.showAlert && widget.alertMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog(context, widget.alertMessage!);
      });
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.getText(
            'authentication_required',
            Provider.of<LanguageProvider>(context, listen: false)
                .currentLocale
                .languageCode)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppTranslations.getText(
                'ok',
                Provider.of<LanguageProvider>(context, listen: false)
                    .currentLocale
                    .languageCode)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Check if there's a target route to redirect to after login
      final targetRoute = await authService.getTargetRoute();
      await authService.clearTargetRoute();

      if (targetRoute != null) {
        Navigator.of(context).pushReplacementNamed(targetRoute);
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
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
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: isRtl
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                prefixIcon: Icon(Icons.email,
                                    color: Theme.of(context).primaryColor),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppTranslations.getText(
                                        'email_required', locale);
                                  }
                                  if (!value.contains('@')) {
                                    return AppTranslations.getText(
                                        'email_invalid', locale);
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                labelText:
                                    AppTranslations.getText('password', locale),
                                hintText: AppTranslations.getText(
                                    'password_hint', locale),
                                controller: _passwordController,
                                obscureText: true,
                                textDirection: isRtl
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                prefixIcon: Icon(Icons.lock,
                                    color: Theme.of(context).primaryColor),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppTranslations.getText(
                                        'password_required', locale);
                                  }
                                  if (value.length < 6) {
                                    return AppTranslations.getText(
                                        'password_length', locale);
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : CustomButton(
                                      text: AppTranslations.getText(
                                          'login', locale),
                                      onPressed: _handleLogin,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
