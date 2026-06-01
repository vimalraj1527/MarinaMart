import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class WalletController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxList<dynamic> requests = <dynamic>[].obs;
  
  final TextEditingController amountController = TextEditingController();
  final TextEditingController couponController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchWalletRequests();
  }

  Future<void> fetchWalletRequests() async {
    try {
      final customerId = _authController.currentUser['id'];
      if (customerId == null) return;

      isLoading.value = true;
      final response = await _apiService.getData('/wallet/request/customer/$customerId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        requests.value = data;
      }
    } catch (e) {
      print("Error fetching wallet requests: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestAddMoney() async {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      Get.snackbar('Input Required', 'Please enter an amount to load.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter a valid amount greater than 0.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      final customerId = _authController.currentUser['id'];
      if (customerId == null) return;

      isLoading.value = true;
      final response = await _apiService.postData('/wallet/request', {
        'customerId': customerId,
        'amount': amount,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        amountController.clear();
        Get.snackbar('Request Submitted', 'Your request for ₹$amount has been sent for admin approval.',
            backgroundColor: Colors.green, colorText: Colors.white);
        await fetchWalletRequests();
      } else {
        final err = jsonDecode(response.body);
        Get.snackbar('Request Failed', err['message'] ?? 'Failed to submit wallet request.',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Connection Error', 'Failed to connect to wallet server.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> redeemCoupon() async {
    final code = couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      Get.snackbar('Input Required', 'Please enter a coupon code.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      final customerId = _authController.currentUser['id'];
      if (customerId == null) return;

      isLoading.value = true;
      final response = await _apiService.postData('/wallet/redeem', {
        'customerId': customerId,
        'code': code,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        couponController.clear();
        
        Get.snackbar('Redeemed successfully!', result['message'] ?? 'Wallet credited.',
            backgroundColor: Colors.green, colorText: Colors.white);
        
        // Refresh local user profile to get updated balance
        await _authController.refreshUserProfile();
      } else {
        final err = jsonDecode(response.body);
        Get.snackbar('Redeem Failed', err['message'] ?? 'Invalid coupon code or already used.',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Connection Error', 'Failed to connect to wallet server.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    couponController.dispose();
    super.onClose();
  }
}
