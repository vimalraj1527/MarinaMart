import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_colors.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 18)),
        centerTitle: false,
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // User Info Header
            Obx(() {
              final user = authController.currentUser;
              return Container(
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
                        boxShadow: [BoxShadow(color: const Color(0xFF6C5CE7).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
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
                      onPressed: () => _showEditProfileDialog(context, authController),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text("EDIT"),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 12),
            
            // Wallet & Birthday Section
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Obx(() {
                    final balance = double.tryParse(authController.currentUser['walletBalance']?.toString() ?? '0') ?? 0.0;
                    return _buildMenuItem(
                      Icons.account_balance_wallet_outlined, 
                      "My Wallet", 
                      subtitle: "₹${balance.toStringAsFixed(2)} Balance",
                      trailingText: "ADD MONEY",
                      onTap: () => Get.toNamed('/wallet'),
                    );
                  }),
                  const Divider(height: 1, indent: 60),
                  Obx(() {
                    final birthday = authController.currentUser['birthday'];
                    String subtitleText = "Add birthday for special surprise gifts!";
                    if (birthday != null && birthday.toString().isNotEmpty) {
                      try {
                        final parsed = DateTime.parse(birthday.toString());
                        final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                        subtitleText = "Birthday: ${parsed.day} ${months[parsed.month - 1]} ${parsed.year}";
                      } catch (_) {
                        subtitleText = "Birthday: $birthday";
                      }
                    }
                    return _buildMenuItem(
                      Icons.cake_outlined, 
                      "Birthday Details", 
                      subtitle: subtitleText,
                      onTap: () => _showBirthdayPicker(context, authController),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 12),

            // Branding Customize Section
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Obx(() => _buildMenuItem(
                    Icons.palette_outlined, 
                    "App Brand Theme", 
                    subtitle: "Current: ${themeController.selectedThemeName}",
                    trailingText: "SWITCH",
                    onTap: () {
                      themeController.showThemeBottomSheet();
                    }
                  )),
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
                child: Text(trailingText, style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
              )
            else
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthController authController) {
    final nameCtrl = TextEditingController(text: authController.currentUser['name']);
    final emailCtrl = TextEditingController(text: authController.currentUser['email']);
    final phoneCtrl = TextEditingController(text: authController.currentUser['phone']);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text("Update your registered profile details", style: TextStyle(color: AppColors.grey)),
              const SizedBox(height: 20),
              
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Contact",
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 24),
              
              Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () async {
                          if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                            Get.snackbar("Incomplete Details", "Please fill in all fields.",
                                backgroundColor: Colors.orange, colorText: Colors.white);
                            return;
                          }
                          String phoneVal = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
                          if (phoneVal.length > 10) {
                            phoneVal = phoneVal.substring(phoneVal.length - 10);
                          }
                          if (phoneVal.length != 10) {
                            Get.snackbar("Invalid Mobile Number", "Mobile number must be exactly 10 digits.",
                                backgroundColor: Colors.orange, colorText: Colors.white);
                            return;
                          }
                          bool success = await authController.updateProfile(
                            nameCtrl.text,
                            emailCtrl.text,
                            phoneVal,
                          );
                          if (success) {
                            Get.back();
                            Get.snackbar(
                              'Profile Updated',
                              'Your profile details have been saved successfully!',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 3),
                              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                    shadowColor: AppColors.primaryColor.withOpacity(0.35),
                  ),
                  child: authController.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showBirthdayPicker(BuildContext context, AuthController authController) async {
    final birthdayStr = authController.currentUser['birthday'];
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    if (birthdayStr != null && birthdayStr.toString().isNotEmpty) {
      try {
        initialDate = DateTime.parse(birthdayStr.toString());
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C5CE7), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black87, // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      bool success = await authController.updateProfile(
        authController.currentUser['name'] ?? '',
        authController.currentUser['email'] ?? '',
        authController.currentUser['phone'] ?? '',
        birthday: formattedDate,
      );
      if (success) {
        Get.snackbar(
          'Birthday Updated',
          'Your birthday details have been saved for surprise gifts!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }
}
