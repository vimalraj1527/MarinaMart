import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import 'orders_controller.dart';
import 'cart_controller.dart';

import '../../services/api_service.dart';
import '../../utils/app_constants.dart';

class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final TextEditingController emailController = TextEditingController(text: 'rvimalrajravi@gmail.com');
  final TextEditingController passwordController = TextEditingController(text: 'User@2026');

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Input Required', 'Provide email and password credentials', 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      print("[AUTH] Starting login request for: $email to ${AppConstants.baseUrl}${AppConstants.loginUrl}");
      
      // ApiService already has a 15s timeout, removing the redundant .timeout(10) here
      final response = await _apiService.postData(AppConstants.loginUrl, {
        'email': email,
        'password': password,
      });

      print("[AUTH] Response Code: ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data.containsKey('access_token')) {
          await _storage.setToken(data['access_token']);
          await _storage.setUser(jsonEncode(data['user']));
          
          Get.offAllNamed('/login_success', arguments: data['user']?['name'] ?? 'Authorized User');
        } else {
           throw Exception("Identity payload missing access_token");
        }
      } else if (response.statusCode == 503) {
         // This is our custom 503 from ApiService when network is unreachable
         _handleConnectionError(null);
      } else {
        try {
           final errData = jsonDecode(response.body);
           Get.snackbar('Login Refused', errData['message'] ?? 'Identity not recognized.', 
               backgroundColor: Colors.red, colorText: Colors.white);
        } catch (_) {
           Get.snackbar('Credential Mismatch', 'Password was rejected by the identity service.', 
               backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
       _handleConnectionError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleConnectionError(dynamic error) {
    print("[CRITICAL] AUTH_LOGIN_FAILURE: $error");
    
    String hint = 'The backend server is unreachable. Ensure yours is running and reachable.';
    if (error?.toString().contains("10.0.2.2") ?? true) {
      hint = "Network unreachable. Verify you ran 'adb reverse tcp:5001 tcp:5001' on your host machine for this device.";
    }
    
    Get.snackbar('Connection Terminated', hint, 
      backgroundColor: Colors.blueGrey.shade900, colorText: Colors.white, 
      duration: const Duration(seconds: 7),
      mainButton: TextButton(
        onPressed: login, 
        child: const Text("Retry", style: TextStyle(color: Colors.greenAccent))
      ));
  }

  Future<void> register(String name, String email, String password, String phone) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      Get.snackbar('Data Incomplete', 'Registry requirements not met.', 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.postData(AppConstants.registerUrl, {
        'name': name.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'phone': phone.trim(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.setToken(data['access_token']);
        await _storage.setUser(jsonEncode(data['user']));
        Get.offAllNamed('/home');
        Get.snackbar('Registry Complete', 'Welcome to the platform!', 
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        try {
           final errData = jsonDecode(response.body);
           Get.snackbar('Registry Error', errData['message'] ?? 'Identity already exists.', 
               backgroundColor: Colors.red, colorText: Colors.white);
        } catch (_) {
           Get.snackbar('Failed', 'Endpoint not reachable.', 
               backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Connection Failure', 'Backend sync interrupted.', 
          backgroundColor: Colors.blueGrey.shade900, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    try {
      await _storage.clearAll();
      
      if (Get.isRegistered<OrdersController>()) {
        Get.delete<OrdersController>(force: true);
      }
      
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearCart();
      }
      
      Get.offAllNamed('/login');
    } catch (e) {
      print("[CRITICAL] LOGOUT_DATA_FAILURE: $e");
      Get.offAllNamed('/login'); 
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
