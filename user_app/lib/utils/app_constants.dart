class AppConstants {
  static const String appName = 'Bloomarina Instamart';
  static const String appVersion = '1.0.0';
  
  // NOTE: If using Android Emulator, use http://10.0.2.2:5001
  // If using Real Device, use your Computer's Local IP (e.g. http://192.168.1.5:5001)
  // Ensure you run 'adb reverse tcp:5001 tcp:5001' for USB-connected real devices.
  static const String baseUrl = 'http://localhost:5001'; 

  // Store Location for Distance-based delivery calculation
  static const double storeLat = 12.9716; 
  static const double storeLong = 77.5946;

  // API Endpoints
  static const String loginUrl = '/auth/login';
  static const String registerUrl = '/auth/register';
  static const String profileUrl = '/users/profile';
  static const String productsUrl = '/products';
  static const String categoriesUrl = '/categories';
  static const String ordersUrl = '/orders';
  static const String bannersUrl = '/banners';
  static const String cartUrl = '/cart';
  static const String supportMessagesUrl = '/support/messages';
  static const String supportSendUrl = '/support/message';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isFirstTime = 'is_first_time';

  // Delivery Overrides
  static const double freeDeliveryThreshold = 499.0;

  // UI Settings (Radius, Spacing etc)
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
}
