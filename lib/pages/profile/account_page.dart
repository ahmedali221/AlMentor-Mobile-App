import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../Core/Providers/language_provider.dart';
import '../../Core/Localization/app_translations.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../auth/loginPage.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AccountPage');

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _logger.info('Loading user data');
      final token = await _authService.getToken();
      if (token != null) {
        final user = await _authService.getCurrentUser();
        if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
        }
      } else {
        if (mounted) {
        setState(() {
          _user = null;
          _isLoading = false;
        });
        }
      }
    } catch (e) {
      _logger.severe('Error loading user data: $e');
      if (mounted) {
      setState(() {
          _errorMessage = e.toString();
        _isLoading = false;
      });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      _logger.info('Logging out user');
      await _authService.logout();
      if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
      }
    } catch (e) {
      _logger.severe('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
    );
  }
    }
  }

  Widget _buildProfileSection(bool isDark, Color surfaceColor) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: surfaceColor.withOpacity(0.2),
                          backgroundImage: _user?.profilePicture != null &&
                                  _user!.profilePicture.isNotEmpty
                              ? NetworkImage(_user!.profilePicture)
                              : null,
                          child: _user?.profilePicture == null ||
                                  _user!.profilePicture.isEmpty
                              ? Icon(Icons.person,
                                  size: 64,
                                  color: isDark
                                      ? surfaceColor.withOpacity(0.5)
                                      : Colors.grey[400])
                              : null,
                        ),
                        const SizedBox(height: 12),
        if (_user != null) ...[
                        Text(
            '${_user!.firstNameEn} ${_user!.lastNameEn}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user!.email,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
        ] else ...[
                        Icon(Icons.person_off,
                            size: 64,
                            color: isDark
                                ? surfaceColor.withOpacity(0.5)
                                : Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          AppTranslations.getText('not_logged_in',
                Localizations.localeOf(context).languageCode),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppTranslations.getText(
                              'please_login_to_view_profile',
                Localizations.localeOf(context).languageCode),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
      ],
    );
  }

  Widget _settingsTile(
      String title, IconData icon, bool isDark, Color onSurface) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
          Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 22),
      trailing: Icon(Icons.arrow_forward_ios,
          color: isDark ? Colors.white : Colors.black54, size: 18),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: onSurface,
            fontSize: 16,
          ),
        ),
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SizedBox(height: 12),
          _buildProfileSection(isDark, surfaceColor),
          const SizedBox(height: 18),
          // Red Card
          Container(
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/jo.png',
                      width: 150,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTranslations.getText('invest_in_yourself',
                            languageProvider.currentLocale.languageCode),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTranslations.getText('enjoy_courses',
                            languageProvider.currentLocale.languageCode),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: languageProvider.isArabic
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/subscribe');
                          },
                          icon: Icon(
                              languageProvider.isArabic
                                  ? Icons.arrow_back
                                  : Icons.arrow_forward,
                              size: 18),
                          label: Text(
                            AppTranslations.getText('subscribe_now',
                                languageProvider.currentLocale.languageCode),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Language Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.language, color: onSurface, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    AppTranslations.getText('language',
                        languageProvider.currentLocale.languageCode),
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        languageProvider.isArabic ? 'العربية' : 'English',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
                onSelected: (String languageCode) {
                  context.read<LanguageProvider>().changeLanguage(languageCode);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Row(
                      children: [
                        const Text('English'),
                        const SizedBox(width: 8),
                        if (!languageProvider.isArabic)
                          const Icon(Icons.check, size: 18),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'ar',
                    child: Row(
                      children: [
                        const Text('العربية'),
                        const SizedBox(width: 8),
                        if (languageProvider.isArabic)
                          const Icon(Icons.check, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: isDark ? Colors.white24 : Colors.black12,
            height: 24,
          ),
          // Settings List
          _settingsTile(
              AppTranslations.getText(
                  'about', languageProvider.currentLocale.languageCode),
              Icons.help_outline,
              isDark,
              onSurface),
          _settingsTile(
              AppTranslations.getText(
                  'terms', languageProvider.currentLocale.languageCode),
              Icons.menu_book_outlined,
              isDark,
              onSurface),
          _settingsTile(
              AppTranslations.getText(
                  'privacy', languageProvider.currentLocale.languageCode),
              Icons.lock_outline,
              isDark,
              onSurface),
          _settingsTile(
              AppTranslations.getText(
                  'help', languageProvider.currentLocale.languageCode),
              Icons.info_outline,
              isDark,
              onSurface),
          const SizedBox(height: 18),
          // Login/Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _user != null
                  ? _logout
                  : () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
              child: Text(
                AppTranslations.getText(_user != null ? 'logout' : 'login',
                    languageProvider.currentLocale.languageCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Version
          Center(
            child: Text(
              '${AppTranslations.getText('version', languageProvider.currentLocale.languageCode)} 1.1.40',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black38,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
