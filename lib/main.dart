import 'package:almentor_clone/Core/Routes/route_generator.dart';
import 'package:almentor_clone/models/payment_model.dart';
import 'package:almentor_clone/pages/categories/categoryCourses.dart';
import 'package:almentor_clone/pages/courses/coursesDetails.dart';
import 'package:almentor_clone/pages/instructors/instructors.dart';
import 'package:almentor_clone/pages/subs%20and%20payment/craditpayment.dart';
import 'package:almentor_clone/pages/subs%20and%20payment/subscribe.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:almentor_clone/Core/Providers/language_provider.dart';
import 'package:almentor_clone/Core/Themes/lightTheme.dart';
import 'package:almentor_clone/Core/Themes/darkTheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/auth/loginPage.dart';
import 'pages/auth/signUpPage.dart';
import 'pages/profile/account_page.dart';
import 'pages/clips_page.dart';
import 'pages/categories/search_page.dart';
import 'pages/home/home_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      Stripe.publishableKey =
          'pk_test_51RPVt0HK6cdy1T9j73EZOjay66JK1G7sS25qBdV7NAsj1axBGobnqlvvu8HLbGH3cE6bmPiPGnmSIM0Hxx7z2hp900mwB8Mphx';
      await Stripe.instance.applySettings();
    } catch (e) {
      print('Stripe init error: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Almentor Clone',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/home', // Always start with home page
          onGenerateRoute: RouteGenerator.generateRoute,
          navigatorObservers: [RouteObserver()],
          routes: {
            '/login': (context) => LoginPage(),
            '/signup': (context) => SignUpPage(),
            '/home': (context) => const HomePage(),
            '/instructors': (context) => const Instructors(),
            '/account': (context) => const AccountPage(),
            '/clips': (context) => const ClipsPage(),
            '/search': (context) => const SearchPage(),
            '/subscribe': (context) => const SubscribePage(),
          },
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}

class RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkProtectedRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _checkProtectedRoute(newRoute);
  }

  void _checkProtectedRoute(Route<dynamic> route) async {
    final authService =
        Provider.of<AuthService>(route.navigator!.context, listen: false);
    final protectedRoutes = [
      '/user_courses',
      '/lessons_viewer',
      '/account',
      '/subscribe'
    ];

    if (protectedRoutes.contains(route.settings.name)) {
      final isLoggedIn = await authService.isLoggedIn();
      if (!isLoggedIn) {
        // Save the target route for redirection after login
        await authService.saveTargetRoute(route.settings.name!);
        Navigator.of(route.navigator!.context).pushReplacementNamed('/login');
      }
    }
  }
}
