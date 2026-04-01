class AppConstants {
  static const String appName = 'Bloomarina Instamart';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'http://10.0.2.2:5001'; // For emulator access
  // For Real device use your PC's IP address: static const String baseUrl = 'http://192.168.x.x:5001';

  // API Endpoints
  static const String loginUrl = '/auth/login';
  static const String registerUrl = '/auth/register';
  static const String profileUrl = '/users/profile';
  static const String productsUrl = '/products';
  static const String categoriesUrl = '/categories';
  static const String ordersUrl = '/orders';
  static const String bannersUrl = '/banners';
  static const String cartUrl = '/cart';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isFirstTime = 'is_first_time';

  // UI Settings (Radius, Spacing etc)
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}
