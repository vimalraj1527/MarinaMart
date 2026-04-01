import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final StorageService storage = Get.find<StorageService>();
    
    // Parse user data
    Map<String, dynamic> user = {};
    String? userStr = storage.getUser();
    if (userStr != null) {
      user = jsonDecode(userStr);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                   const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['name'] ?? "User",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user['email'] ?? "Email not provided",
                    style: const TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Menu Items
            _buildMenuItem(Icons.shopping_bag_outlined, "My Orders", () => Get.toNamed('/orders')),
            _buildMenuItem(Icons.location_on_outlined, "My Addresses", () => Get.toNamed('/addresses')),
            _buildMenuItem(Icons.payment_outlined, "Payments", () => Get.toNamed('/payments')),
            _buildMenuItem(Icons.notifications_none_outlined, "Notifications", () => Get.toNamed('/notifications')),
            _buildMenuItem(Icons.support_agent_outlined, "Customer Support", () => Get.toNamed('/support')),
            _buildMenuItem(Icons.info_outline, "About Us", () => Get.toNamed('/about')),
            
            const SizedBox(height: 20),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => authController.logout(),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text("Sign Out", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        onTap: onTap,
      ),
    );
  }
}
