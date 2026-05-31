import 'package:flutter/material.dart';
import '../controllers/theme_controller.dart';

class AppColors {
  static Color get primaryColor => ThemeController.to.primaryColor;
  static Color get primaryLight => ThemeController.to.primaryLight;
  static Color get secondaryColor => ThemeController.to.secondaryColor;
  static Color get accentColor => ThemeController.to.accentColor;
  
  static Color get backgroundColor => ThemeController.to.backgroundColor;
  static const Color white = Colors.white;
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradient for a premium feel
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
