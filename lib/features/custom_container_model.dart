import 'package:flutter/material.dart';

class CustomButtonModel {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  CustomButtonModel({
    required this.icon,
    required this.title,
    required this.onPressed,
  });
}
