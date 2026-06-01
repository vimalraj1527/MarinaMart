import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../utils/app_constants.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  Map<String, String> _getHeaders() {
    String? token = _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET Request
  Future<http.Response> getData(String uri) async {
    try {
      final fullUrl = AppConstants.baseUrl + uri;
      print("[API] GET: $fullUrl");
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      print("[CRITICAL] API_GET_ERROR: $e at $uri");
      return http.Response(jsonEncode({'message': 'Unreachable: $e'}), 503);
    }
  }

  // POST Request
  Future<http.Response> postData(String uri, dynamic body) async {
    try {
      final fullUrl = AppConstants.baseUrl + uri;
      print("[API] POST: $fullUrl");
      final response = await http.post(
        Uri.parse(fullUrl),
        body: jsonEncode(body),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      print("[CRITICAL] API_POST_ERROR: $e at $uri");
      return http.Response(jsonEncode({'message': 'Unreachable: $e'}), 503);
    }
  }

  // PUT Request
  Future<http.Response> putData(String uri, dynamic body) async {
    try {
      final fullUrl = AppConstants.baseUrl + uri;
      final response = await http.put(
        Uri.parse(fullUrl),
        body: jsonEncode(body),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      print("[CRITICAL] API_PUT_ERROR: $e at $uri");
      return http.Response(jsonEncode({'message': 'Unreachable: $e'}), 503);
    }
  }

  // PATCH Request
  Future<http.Response> patchData(String uri, dynamic body) async {
    try {
      final fullUrl = AppConstants.baseUrl + uri;
      print("[API] PATCH: $fullUrl");
      final response = await http.patch(
        Uri.parse(fullUrl),
        body: jsonEncode(body),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      print("[CRITICAL] API_PATCH_ERROR: $e at $uri");
      return http.Response(jsonEncode({'message': 'Unreachable: $e'}), 503);
    }
  }

  // DELETE Request
  Future<http.Response> deleteData(String uri) async {
    try {
      final fullUrl = AppConstants.baseUrl + uri;
      final response = await http.delete(
        Uri.parse(fullUrl),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      print("[CRITICAL] API_DELETE_ERROR: $e at $uri");
      return http.Response(jsonEncode({'message': 'Unreachable: $e'}), 503);
    }
  }
}
