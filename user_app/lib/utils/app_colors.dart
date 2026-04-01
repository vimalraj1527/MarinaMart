import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF0C831F); // Emerald Green
  static const Color primaryLight = Color(0xFF2EAF4E);
  static const Color secondaryColor = Color(0xFFFABD05); // Gold/Yellow
  static const Color accentColor = Color(0xFFE50914); // For discounts/sale (Red)
  
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color white = Colors.white;
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradient for a premium feel
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
