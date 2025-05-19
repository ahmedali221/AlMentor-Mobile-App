import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFeb2027),
  iconTheme: IconThemeData(
    color: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.grey[900],
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFFeb2027),
    secondary: const Color(0xFFeb2027),
    surface: Colors.grey[850]!,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFFeb2027),
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Colors.grey[850],
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFeb2027),
      foregroundColor: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
);
