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

  // Logout/Clear Storage
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // First Time Check
  bool isFirstTime() {
    return _prefs.getBool(AppConstants.isFirstTime) ?? true;
  }

  Future<void> setNotFirstTime() async {
    await _prefs.setBool(AppConstants.isFirstTime, false);
  }
}
