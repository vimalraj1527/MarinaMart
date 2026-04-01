import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../views/home/home_view.dart';
import 'orders_controller.dart';
import 'cart_controller.dart';

import '../../services/api_service.dart';
import '../../utils/app_constants.dart';

class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

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
      
      final response = await _apiService.postData(AppConstants.loginUrl, {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.setToken(data['access_token']);
        await _storage.setUser(jsonEncode(data['user']));
        Get.offAllNamed('/home');
        Get.snackbar('Success', 'Welcome back, ${data['user']['name']}', 
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Login Failed', data['message'] ?? 'Invalid credentials', 
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
       print("LOGIN_ERROR: $e");
       Get.snackbar('Error', 'Connection failed. Please check your network and try again.', 
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password, String phone) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      Get.snackbar('Error', 'All fields are required', 
          backgroundColor: Colors.red, colorText: Colors.white);
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
        Get.snackbar('Success', 'Account created successfully!', 
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Registration Failed', data['message'] ?? 'Email already exists', 
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed. Check backend.', 
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    try {
      await _storage.clearAll();
      
      // Clear data but keep mandatory controllers alive to avoid crashes
      if (Get.isRegistered<OrdersController>()) {
        Get.delete<OrdersController>(force: true);
      }
      
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearCart();
      }
      
      Get.offAllNamed('/login');
      print("LOGOUT: Data cleared and navigated to login.");
    } catch (e) {
      print("LOGOUT_ERROR: $e");
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
