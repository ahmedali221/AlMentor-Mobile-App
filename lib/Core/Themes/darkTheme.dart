import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFeb2027),
  scaffoldBackgroundColor: const Color(0xFF1A1A1A),
  iconTheme: const IconThemeData(
    color: Colors.white,
    size: 24,
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFFeb2027),
    secondary: Colors.white,
    surface: const Color(0xFF2C2C2C),
    background: const Color(0xFF1A1A1A),
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2C2C2C),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF2C2C2C),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF2C2C2C),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF3D3D3D),
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
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: Color(0xFFAAAAAA),
      fontSize: 14,
    ),
  ),
);
