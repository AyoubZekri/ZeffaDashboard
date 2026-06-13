import 'package:flutter/material.dart';

class AppColor {
  // Primary Theme Colors (Purple Gradient)
  static const Color primaryPurple = Color(0xFF673AB7);
  static const Color accentPurple = Color(0xFF8E24AA);
  static const Color deepPurple = Color(0xFF512DA8);

  // Primary theme colors (Navy/Royal Blue)

  static const Color lightBlue = Color(0xFFE7F0FF);

  static const List<Color> purpleGradient = [
    Color(0xFF8E24AA),
    Color(0xFF512DA8),
  ];

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF8E8E8E);
  static const Color red = Colors.red;

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF3F4F9);
  static const Color backgroundDark = Color(0xFF0F0F1A); // Sleek dark blue/black
  static const Color surfaceDark = Color(0xFF1B1B2F);
  
  // Sidebar Colors
  static const Color sidebarLight = Colors.white;
  static const Color sidebarDark = Color(0xFF1B1B2F);

  // Text Colors
  static const Color textLight = Color(0xFF2D2D2D);
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF8E92BC);

  // Aliases to fix lint errors
  static const Color primarycolor = primaryPurple;
  static const Color backgroundcolor = backgroundLight;
}
