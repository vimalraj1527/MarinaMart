import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with TickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

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
      backgroundColor: const Color(0xFFF7F9FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.5),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Glowing Orbs
          Positioned(
            top: 50, right: -50,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(math.sin(_floatController.value * 2 * math.pi) * 40, math.cos(_floatController.value * 2 * math.pi) * 40),
                  child: Container(
                    width: 250, height: 250, 
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFD700).withOpacity(0.15)),
                  ),
                );
              }
            ),
          ),
          Positioned(
            bottom: 100, left: -50,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(math.sin((_floatController.value + 0.5) * 2 * math.pi) * 40, math.cos((_floatController.value + 0.5) * 2 * math.pi) * 40),
                  child: Container(
                    width: 300, height: 300, 
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor.withOpacity(0.1)),
                  ),
                );
              }
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox(),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // Header Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing outer ring
                              AnimatedBuilder(
                                animation: _floatController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (math.sin(_floatController.value * 4 * math.pi) * 0.05),
                                    child: Container(
                                      width: 110, height: 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: [AppColors.primaryColor.withOpacity(0.5), const Color(0xFFFFD700).withOpacity(0.5)]),
                                      ),
                                    ),
                                  );
                                }
                              ),
                              Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                                ),
                                child: const Icon(Icons.person_rounded, size: 50, color: Color(0xFF3B4371)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user['name'] ?? "User",
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              user['email'] ?? "Email not provided",
                              style: const TextStyle(color: AppColors.primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Menu Items Group 1
                    const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 10, bottom: 10), child: Text("ACCOUNT", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black54, letterSpacing: 1.5)))),
                    _buildMenuGroup([
                      _buildMenuItem(Icons.shopping_bag_rounded, "My Orders", () => Get.toNamed('/orders'), isFirst: true),
                      _buildMenuItem(Icons.location_on_rounded, "My Addresses", () => Get.toNamed('/addresses')),
                      _buildMenuItem(Icons.payment_rounded, "Payment Methods", () => Get.toNamed('/payments'), isLast: true),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    // Menu Items Group 2
                    const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 10, bottom: 10), child: Text("GENERAL", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black54, letterSpacing: 1.5)))),
                    _buildMenuGroup([
                      _buildMenuItem(Icons.notifications_active_rounded, "Notifications", () => Get.toNamed('/notifications'), isFirst: true),
                      _buildMenuItem(Icons.support_agent_rounded, "Customer Support", () => Get.toNamed('/support')),
                      _buildMenuItem(Icons.info_rounded, "About Us", () => Get.toNamed('/about'), isLast: true),
                    ]),
                    
                    const SizedBox(height: 40),
                    
                    // Logout Button
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [BoxShadow(color: AppColors.error.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => authController.logout(),
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        label: const Text("Sign Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isFirst = false, bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(top: Radius.circular(isFirst ? 24 : 0), bottom: Radius.circular(isLast ? 24 : 0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87))),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
