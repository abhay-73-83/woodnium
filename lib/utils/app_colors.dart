import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8B5E3C); // Wood Brown
  static const Color secondary = Color(0xFFD2B48C); // Light Wood Beige
  static const Color accent = Color(0xFFA0522D); // Rustic Brown
  static const Color background = Color(0xFFF5F5F5); // Soft Light
  
  static const Color textPrimary = Color(0xFF3E2723); // Dark wood text
  static const Color textSecondary = Color(0xFF5D4037);
  
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Gradient for headers / splash
  static const LinearGradient woodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5E3C), // primary
      Color(0xFFA0522D), // accent
    ],
  );
}
