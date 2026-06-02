import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const String privacyPolicyContent = """
Last Updated: June 2026

At Bloomarina Instamart, your privacy is our top priority. This Privacy Policy outlines how we collect, use, and protect your information.

1. Information We Collect
We collect personal information that you provide to us, including:
• Name, Email address, and Phone number.
• Live GPS location coordinates and saved delivery addresses (including landmark, floor, and contact details).
• Transaction history and Wallet ledger details.

2. How We Use Your Information
We use your data to:
• Process and fulfill your grocery orders.
• Calculate accurate delivery charges using distance logic.
• Manage your Bloomarina Wallet balance and transactions.
• Send order confirmation and real-time delivery status tracking updates.

3. Sharing of Information
We only share information necessary for fulfillment, such as sharing your delivery address and name with assigned Delivery Partners. We do not sell or trade your personal data.

4. Data Security
We implement industry-standard technical measures (API encryption, authorization checks) to safeguard your data from unauthorized access or leakage.
""";

  static const String termsOfServiceContent = """
Last Updated: June 2026

Welcome to Bloomarina Instamart. By using our application, you agree to comply with and be bound by the following Terms of Service.

1. User Account
• You must create a verified account to use our delivery services.
• You are responsible for keeping your login credentials secure.

2. Order Placement & Fulfillment
• All orders are subject to store inventory and stock availability.
• Delivery charges are calculated dynamically based on the straight-line distance from our store to your confirmed GPS address.

3. Wallet & Payments
• We support payments via Cash on Delivery (COD) and the Bloomarina Wallet.
• Users can load funds into their wallet subject to Admin approval.
• Rejected or cancelled orders will be refunded back to your Wallet balance.

4. User Conduct
• You agree not to manipulate GPS location settings to alter delivery fees.
• Any attempt to abuse coupons or simulate fake wallet requests will lead to permanent account suspension.
""";

  static const String dataProtectionContent = """
Last Updated: June 2026

Bloomarina Instamart is committed to maintaining high standards of data protection and protecting your digital rights.

1. GPS Location Usage
• The application requests location access to identify nearby delivery zones.
• GPS coordinates are only tracked when you explicitly search or pin your address during checkout or saving flow.

2. Data Retention Policy
• We retain your account data and transaction logs for as long as your account is active.
• You can request the deletion of your account and personal history at any time by contacting our support line.

3. Security Safeguards
• All communication between the User App, Admin Panel, and Backend API is secured via HTTPS/TLS protocols.
• Database backups are encrypted and stored in secure cloud environments.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("About Us", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Outfit")),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.shopping_cart, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Bloomarina Instamart",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor, fontFamily: "Outfit"),
            ),
            const Text("Version 1.0.0", style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500)),
            
            const SizedBox(height: 32),
            const Text(
              "At Bloomarina, we are committed to bringing the freshest groceries to your doorstep in minutes. Our mission is to simplify your life through technology, quality, and speed.",
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, fontSize: 14, color: Colors.black87),
            ),
            
            const SizedBox(height: 32),
            _buildAboutRow(
              Icons.policy_outlined, 
              "Privacy Policy",
              () => Get.to(() => const DocumentDetailView(title: "Privacy Policy", content: privacyPolicyContent)),
            ),
            _buildAboutRow(
              Icons.description_outlined, 
              "Terms of Service",
              () => Get.to(() => const DocumentDetailView(title: "Terms of Service", content: termsOfServiceContent)),
            ),
            _buildAboutRow(
              Icons.security_outlined, 
              "Data Protection",
              () => Get.to(() => const DocumentDetailView(title: "Data Protection Policies", content: dataProtectionContent)),
            ),
            
            const SizedBox(height: 48),
            const Text("© 2026 Bloomarina Inc.", style: TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey),
        onTap: onTap,
      ),
    );
  }
}

class DocumentDetailView extends StatelessWidget {
  final String title;
  final String content;

  const DocumentDetailView({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Outfit")),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
