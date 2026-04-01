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
      final response = await http.get(
        Uri.parse(AppConstants.baseUrl + uri),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'No internet connection or timeout'}), 503);
    }
  }

  // POST Request
  Future<http.Response> postData(String uri, dynamic body) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.baseUrl + uri),
        body: jsonEncode(body),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'No internet connection or timeout'}), 503);
    }
  }

  // PUT Request
  Future<http.Response> putData(String uri, dynamic body) async {
    try {
      final response = await http.put(
        Uri.parse(AppConstants.baseUrl + uri),
        body: jsonEncode(body),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'No internet connection or timeout'}), 503);
    }
  }

  // DELETE Request
  Future<http.Response> deleteData(String uri) async {
    try {
      final response = await http.delete(
        Uri.parse(AppConstants.baseUrl + uri),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return response;
    } catch (e) {
      return http.Response(jsonEncode({'message': 'No internet connection or timeout'}), 503);
    }
  }
}
