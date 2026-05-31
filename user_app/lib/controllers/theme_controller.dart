import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class AppTheme {
  final String name;
  final Color primaryColor;
  final Color primaryLight;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final String description;
  final String logoUrl;
  final String loginBannerUrl;

  const AppTheme({
    required this.name,
    required this.primaryColor,
    required this.primaryLight,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.description,
    required this.logoUrl,
    required this.loginBannerUrl,
  });
}

class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();

  final _selectedThemeName = 'Blinkit'.obs;
  String get selectedThemeName => _selectedThemeName.value;

  final Map<String, AppTheme> themes = {
    'Blinkit': const AppTheme(
      name: 'Blinkit',
      primaryColor: Color(0xFF0C831F),
      primaryLight: Color(0xFFE8F5E9),
      secondaryColor: Color(0xFFF7D117),
      accentColor: Color(0xFFD32F2F),
      backgroundColor: Color(0xFFF7F7F7),
      surfaceColor: Colors.white,
      description: 'Forest green & iconic yellow. Clean, readable, and highly trusted.',
      logoUrl: 'https://cdn-icons-png.flaticon.com/512/3724/3724720.png',
      loginBannerUrl: 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?auto=format&fit=crop&w=800&q=80',
    ),
    'Zepto': const AppTheme(
      name: 'Zepto',
      primaryColor: Color(0xFF5F25D9),
      primaryLight: Color(0xFFF2EEFD),
      secondaryColor: Color(0xFFFFD117),
      accentColor: Color(0xFFFF007F),
      backgroundColor: Color(0xFFF8F7FC),
      surfaceColor: Colors.white,
      description: 'Vibrant purple with gold accents. Ultra-fast grocery experience.',
      logoUrl: 'https://cdn-icons-png.flaticon.com/512/9198/9198446.png',
      loginBannerUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80',
    ),
    'Swiggy Instamart': const AppTheme(
      name: 'Swiggy Instamart',
      primaryColor: Color(0xFFFC8019),
      primaryLight: Color(0xFFFFF0E0),
      secondaryColor: Color(0xFF3D2E7C),
      accentColor: Color(0xFFE23744),
      backgroundColor: Color(0xFFFDFBF7),
      surfaceColor: Colors.white,
      description: 'Bright orange and deep navy. The pioneer of instant deliveries.',
      logoUrl: 'https://cdn-icons-png.flaticon.com/512/8201/8201726.png',
      loginBannerUrl: 'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?auto=format&fit=crop&w=800&q=80',
    ),
    'Zomato': const AppTheme(
      name: 'Zomato',
      primaryColor: Color(0xFFE23744),
      primaryLight: Color(0xFFFFEBEC),
      secondaryColor: Color(0xFF1C1C1C),
      accentColor: Color(0xFFFABD05),
      backgroundColor: Color(0xFFFFF9F9),
      surfaceColor: Colors.white,
      description: 'Passionate red and midnight black. Food and grocery culture combined.',
      logoUrl: 'https://cdn-icons-png.flaticon.com/512/3443/3443429.png',
      loginBannerUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=80',
    ),
  };

  AppTheme get currentTheme => themes[_selectedThemeName.value] ?? themes['Blinkit']!;

  Color get primaryColor => currentTheme.primaryColor;
  Color get primaryLight => currentTheme.primaryLight;
  Color get secondaryColor => currentTheme.secondaryColor;
  Color get accentColor => currentTheme.accentColor;
  Color get backgroundColor => currentTheme.backgroundColor;
  Color get surfaceColor => currentTheme.surfaceColor;

  @override
  void onInit() {
    super.onInit();
    final storage = Get.find<StorageService>();
    final savedTheme = storage.getTheme();
    if (savedTheme != null && themes.containsKey(savedTheme)) {
      _selectedThemeName.value = savedTheme;
    }
  }

  void changeTheme(String themeName) {
    if (themes.containsKey(themeName)) {
      _selectedThemeName.value = themeName;
      final storage = Get.find<StorageService>();
      storage.setTheme(themeName);
      
      // Update system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: (themeName == 'Blinkit') ? Brightness.dark : Brightness.light,
        statusBarBrightness: (themeName == 'Blinkit') ? Brightness.light : Brightness.dark,
      ));

      // Update GetMaterialApp theme dynamically
      Get.changeTheme(ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          error: currentTheme.accentColor,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        appBarTheme: AppBarTheme(
          elevation: 0.5,
          centerTitle: false,
          backgroundColor: surfaceColor,
          foregroundColor: Colors.black87,
        ),
        useMaterial3: true,
      ));
      
      Get.forceAppUpdate();
    }
  }

  void showThemeBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select App Brand Theme",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Experience the app in your favorite UI style",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...themes.values.map((theme) {
              final isSelected = selectedThemeName == theme.name;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryLight.withOpacity(0.3) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    changeTheme(theme.name);
                    Get.back();
                    Get.snackbar(
                      "Theme Switched",
                      "App rebranded to ${theme.name} style!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: theme.primaryColor,
                      colorText: theme.name == 'Blinkit' ? Colors.black87 : Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        theme.name[0],
                        style: TextStyle(
                          color: theme.name == 'Blinkit' ? Colors.black87 : Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    theme.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: theme.primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    theme.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: theme.primaryColor, size: 26)
                      : null,
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
