import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFeb2027),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  iconTheme: const IconThemeData(
    color: Color(0xFF2C2C2C),
    size: 24,
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFeb2027),
    secondary: Color(0xFF2C2C2C),
    surface: Colors.white,
    onSurface: Color(0xFF2C2C2C),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF2C2C2C),
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Color(0xFF2C2C2C)),
    titleTextStyle: TextStyle(
      color: Color(0xFF2C2C2C),
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Colors.white,
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFEEEEEE),
    thickness: 1,
    space: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFeb2027),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Color(0xFF2C2C2C),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Color(0xFF2C2C2C),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Color(0xFF2C2C2C),
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: Color(0xFF2C2C2C),
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFF666666),
      fontSize: 14,
    ),
  ),
);
