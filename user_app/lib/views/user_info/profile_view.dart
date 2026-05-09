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
    
    Map<String, dynamic> user = {};
    String? userStr = storage.getUser();
    if (userStr != null) {
      user = jsonDecode(userStr);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Blinkit minimal grey background
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 18)),
        centerTitle: false,
        elevation: 0.5, // Slight shadow for clean separation
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // User Info Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFa29bfe)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: const Color(0xFF6C5CE7).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text(
                        (user['name']?.toString() ?? 'U').isNotEmpty ? (user['name']?.toString() ?? 'U')[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? "User",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['email'] ?? "Email not provided",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text("EDIT"),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Wallet & Birthday Section
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.account_balance_wallet_outlined, 
                    "My Wallet", 
                    subtitle: "₹0.00 Balance",
                    trailingText: "ADD MONEY",
                    onTap: () {
                      Get.snackbar("Wallet", "Wallet feature coming soon!", backgroundColor: Colors.black87, colorText: Colors.white);
                    }
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(
                    Icons.cake_outlined, 
                    "Birthday Details", 
                    subtitle: "Add birthday for special surprise gifts!",
                    onTap: () {
                      Get.snackbar("Birthday", "Birthday setup coming soon!", backgroundColor: Colors.black87, colorText: Colors.white);
                    }
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Orders & Addresses Section
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(Icons.shopping_bag_outlined, "Your Orders", onTap: () => Get.toNamed('/orders')),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(Icons.location_on_outlined, "Address Book", onTap: () => Get.toNamed('/addresses')),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(Icons.payment_outlined, "Payment Methods", onTap: () => Get.toNamed('/payments')),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // General & Support Section
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(Icons.notifications_none_outlined, "Notifications", onTap: () => Get.toNamed('/notifications')),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(Icons.support_agent_outlined, "Customer Support", onTap: () => Get.toNamed('/support')),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(Icons.info_outline_rounded, "About Us", onTap: () => Get.toNamed('/about')),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => authController.logout(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade200, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, String? trailingText, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black87, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey.shade600)),
                  ]
                ],
              ),
            ),
            if (trailingText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(trailingText, style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
              )
            else
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }
}
