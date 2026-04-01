import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../views/home/home_view.dart';

class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxBool isLoading = false.obs;
  final TextEditingController emailController = TextEditingController(text: 'tech@bloomarina.com');
  final TextEditingController passwordController = TextEditingController(text: '123456');

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password', 
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      // Hardcoded Login for DEV Purpose
      if (emailController.text == 'tech@bloomarina.com' && passwordController.text == '123456') {
        const String mockToken = "dev_mock_token_123456";
        final Map<String, dynamic> mockUser = {
          "id": "dev_id_001",
          "name": "Bloomarina Dev",
          "email": "tech@bloomarina.com",
          "role": "USER",
          "avatar": null
        };

        await _storage.setToken(mockToken);
        await _storage.setUser(jsonEncode(mockUser));

        Get.offAll(() => const HomeView());
        Get.snackbar('Success', 'Logged in as Developer', 
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Login Failed', 'Use dev credentials', 
            backgroundColor: Colors.red, colorText: Colors.white);
      }

      /* 
      // REAL API CALL (COMMENTED FOR DEV)
      final response = await _apiService.postData(AppConstants.loginUrl, {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      });
      ...
      */
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong. Please try again.', 
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _storage.clearAll();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
