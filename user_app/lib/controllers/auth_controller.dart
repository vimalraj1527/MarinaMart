import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import 'orders_controller.dart';
import 'cart_controller.dart';

import '../../services/api_service.dart';
import '../../utils/app_constants.dart';

class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;

  bool get isBirthdayToday {
    final birthdayStr = currentUser['birthday']?.toString();
    if (birthdayStr == null || birthdayStr.isEmpty) return false;
    try {
      final parts = birthdayStr.split('-');
      if (parts.length < 3) return false;
      final birthMonth = int.tryParse(parts[1]);
      final birthDay = int.tryParse(parts[2]);
      if (birthMonth == null || birthDay == null) return false;

      final now = DateTime.now();
      return now.month == birthMonth && now.day == birthDay;
    } catch (e) {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    String? userStr = _storage.getUser();
    if (userStr != null) {
      try {
        currentUser.value = jsonDecode(userStr);
      } catch (e) {
        print("Error decoding user in AuthController: $e");
      }
    }
  }

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
        'username': email,
        'phone': email,
        'password': password,
      });

      print("[AUTH] Response Code: ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data.containsKey('access_token')) {
          await _storage.setToken(data['access_token']);
          await _storage.setUser(jsonEncode(data['user']));
          currentUser.value = data['user'] ?? {};
          
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

  Future<void> register(String name, String email, String password, String phone, String birthday) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty || birthday.isEmpty) {
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
        'birthday': birthday.trim(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.setToken(data['access_token']);
        await _storage.setUser(jsonEncode(data['user']));
        currentUser.value = data['user'] ?? {};
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
      currentUser.clear();
      
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

  Future<bool> updateProfile(String name, String email, String phone, {String? birthday}) async {
    try {
      isLoading.value = true;
      final userId = currentUser['id'];
      if (userId == null) return false;

      final Map<String, dynamic> body = {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
      };
      if (birthday != null) {
        body['birthday'] = birthday;
      }

      final response = await _apiService.patchData('/users/$userId', body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedUser = jsonDecode(response.body);
        await _storage.setUser(jsonEncode(updatedUser));
        currentUser.value = updatedUser;
        return true;
      } else {
        final errData = jsonDecode(response.body);
        Get.snackbar('Error', errData['message'] ?? 'Failed to update profile.', 
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed. Try again.', 
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUserProfile() async {
    try {
      final userId = currentUser['id'];
      if (userId == null) return;
      final response = await _apiService.getData('/users/$userId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = jsonDecode(response.body);
        await _storage.setUser(jsonEncode(userData));
        currentUser.value = userData;
      }
    } catch (e) {
      print("Error refreshing user profile: $e");
    }
  }

  Future<bool> sendOtp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10) {
      Get.snackbar('Invalid Mobile', 'Enter a valid 10-digit phone number',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.postData('/auth/send-otp', {
        'phone': cleanPhone,
        'appName': AppConstants.appName,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String? otpCode = data['otp']?.toString();

        // Direct call to My Dreams Technology SMS Provider Gateway
        if (otpCode != null && otpCode.isNotEmpty) {
          try {
            final apiKey = 'pdtPO9aL4m8RSQTV';
            final senderId = 'MDTDMO';
            final msg = Uri.encodeComponent("Dear $otpCode, Your OTP for login to ${AppConstants.appName}. Valid for 30 minutes. Please do not share this OTP. Regards, My Dreams Technology Team");
            final smsProviderUrl = "http://app.mydreamstechnology.in/vb/apikey.php?apikey=$apiKey&senderid=$senderId&number=$cleanPhone&message=$msg";
            print("[SMS-PROVIDER] Dispatching directly to: $smsProviderUrl");
            http.get(Uri.parse(smsProviderUrl));
          } catch (err) {
            print("[SMS-PROVIDER] Direct call exception: $err");
          }
        }

        Get.snackbar(
          'OTP Sent Successfully',
          data['message'] ?? 'OTP code sent via SMS to +91 $cleanPhone',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.mark_email_read_rounded, color: Colors.white),
        );
        return true;
      } else {
        final err = jsonDecode(response.body);
        Get.snackbar('OTP Failed', err['message'] ?? 'Failed to send OTP.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Network Failure', 'Could not connect to SMS server.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtpAndLogin(String phone, String otp, {Map<String, dynamic>? signupData}) async {
    if (otp.trim().length < 4) {
      Get.snackbar('OTP Required', 'Enter the OTP received on your mobile.',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      final response = await _apiService.postData('/auth/verify-otp', {
        'phone': cleanPhone,
        'otp': otp.trim(),
        'userData': signupData,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('access_token')) {
          await _storage.setToken(data['access_token']);
          await _storage.setUser(jsonEncode(data['user']));
          currentUser.value = data['user'] ?? {};

          final bool isNew = data['isNewUser'] == true || 
                             (data['user']?['name']?.toString().startsWith('User ') ?? false) ||
                             (data['user']?['email']?.toString().contains('@marinamart.com') ?? false);

          if (isNew && signupData == null) {
            // Redirect to Signup setup screen for profile completion
            Get.offNamed('/signup', arguments: {'isSetup': true, 'phone': cleanPhone});
            Get.snackbar(
              'Mobile Verified!',
              'Please complete your name & basic details to finish setup.',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
              icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
            );
          } else {
            Get.offAllNamed('/login_success', arguments: data['user']?['name'] ?? 'Authorized User');
          }
        }
      } else {
        final errData = jsonDecode(response.body);
        Get.snackbar('Verification Failed', errData['message'] ?? 'Invalid OTP code.',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Verification Error', 'Network error. Try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
