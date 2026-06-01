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
}
