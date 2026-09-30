class AppConstants {
  static const String appName = 'MaRinaMaRt';
  static const String appVersion = '1.0.0';
  
  // ── SERVER ENVIRONMENT TOGGLE ──────────────────────────────────────────────
  // Set `useLiveServer = true` to connect to Live Production Server.
  // Set `useLiveServer = false` to connect to Localhost Server.
  static const bool useLiveServer = true;

  static const String liveServerUrl = 'https://marinamart.onrender.com';
  static const String localServerUrl = 'http://localhost:5001'; 
  // NOTE: For Android Emulator use 'http://10.0.2.2:5001', for Real Mobile Device use 'http://192.168.1.X:5001'

  static const String baseUrl = useLiveServer ? liveServerUrl : localServerUrl; 

  // Store Location Hub for Distance-based delivery calculation (MarinaMart Hub - Chennai)
  // Dynamic store location is fetched from Backend Admin Settings; these serve as default store coordinates.
  static const double storeLat = 13.0473; 
  static const double storeLong = 80.2824;

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
