import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Token Management
  Future<void> setToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  // User Data Management
  Future<void> setUser(String userData) async {
    await _prefs.setString(AppConstants.userKey, userData);
  }

  String? getUser() {
    return _prefs.getString(AppConstants.userKey);
  }

  // Platform Settings (Synced from Backend)
  Future<void> setSettings(String settingsData) async {
    await _prefs.setString('platform_settings', settingsData);
  }

  String? getSettings() {
    return _prefs.getString('platform_settings');
  }

  // App Theme Management
  Future<void> setTheme(String themeName) async {
    await _prefs.setString('app_theme', themeName);
  }

  String? getTheme() {
    return _prefs.getString('app_theme');
  }

  // Logout/Clear Storage
  Future<void> clearAll() async {
    // Save theme before clearing
    final theme = getTheme();
    await _prefs.clear();
    if (theme != null) {
      await setTheme(theme);
    }
  }

  bool isFirstTime() {
    return _prefs.getBool(AppConstants.isFirstTime) ?? true;
  }

  Future<void> setNotFirstTime() async {
    await _prefs.setBool(AppConstants.isFirstTime, false);
  }

  // Recent Searches Management
  Future<void> saveRecentSearches(List<String> searches) async {
    await _prefs.setStringList('recent_searches', searches);
  }

  List<String> getRecentSearches() {
    return _prefs.getStringList('recent_searches') ?? [];
  }

  // Favorites Management
  Future<void> saveFavorites(List<String> favIds) async {
    await _prefs.setStringList('favorite_products', favIds);
  }

  List<String> getFavorites() {
    return _prefs.getStringList('favorite_products') ?? [];
  }

  // Birthday Greeting Tracker
  int? getLastBirthdayGreetingTime() {
    return _prefs.getInt('last_birthday_greeting_time');
  }

  Future<void> setLastBirthdayGreetingTime(int time) async {
    await _prefs.setInt('last_birthday_greeting_time', time);
  }

  // Location Preference Persistence
  Future<void> saveUserLocation(String shortAddr, String fullAddr, double lat, double lon) async {
    await _prefs.setString('user_short_addr', shortAddr);
    await _prefs.setString('user_full_addr', fullAddr);
    await _prefs.setDouble('user_lat', lat);
    await _prefs.setDouble('user_lon', lon);
  }

  Map<String, dynamic>? getUserLocation() {
    String? shortAddr = _prefs.getString('user_short_addr');
    String? fullAddr = _prefs.getString('user_full_addr');
    double? lat = _prefs.getDouble('user_lat');
    double? lon = _prefs.getDouble('user_lon');

    if (shortAddr != null && fullAddr != null) {
      return {
        'short': shortAddr,
        'full': fullAddr,
        'lat': lat ?? 0.0,
        'lon': lon ?? 0.0,
      };
    }
    return null;
  }

  // Saved Addresses Persistence
  Future<void> saveSavedAddresses(List<Map<String, String>> addresses) async {
    List<String> encoded = addresses.map((a) => jsonEncode(a)).toList();
    await _prefs.setStringList('user_saved_addresses_list', encoded);
  }

  List<Map<String, String>> getSavedAddresses() {
    List<String>? encoded = _prefs.getStringList('user_saved_addresses_list');
    if (encoded != null && encoded.isNotEmpty) {
      try {
        return encoded.map<Map<String, String>>((item) {
          final Map<String, dynamic> decoded = jsonDecode(item);
          return decoded.map((k, v) => MapEntry(k, v.toString()));
        }).toList();
      } catch (e) {
        print("Error parsing saved addresses: $e");
      }
    }
    return [];
  }
}
