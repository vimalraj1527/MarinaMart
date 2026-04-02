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

  // PLATFORM SETTINGS (Synced from Backend)
  Future<void> setSettings(String settingsData) async {
    await _prefs.setString('platform_settings', settingsData);
  }

  String? getSettings() {
    return _prefs.getString('platform_settings');
  }

  // Logout/Clear Storage
  Future<void> clearAll() async {
    // We clear credentials but maybe we keep platform settings?
    // Usually better to clear everything and re-fetch.
    await _prefs.clear();
  }

  bool isFirstTime() {
    return _prefs.getBool(AppConstants.isFirstTime) ?? true;
  }

  Future<void> setNotFirstTime() async {
    await _prefs.setBool(AppConstants.isFirstTime, false);
  }
}
