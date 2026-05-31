import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
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
                child: Icon(Icons.shopping_cart, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Bloomarina Instamart",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
            ),
            const Text("Version 1.0.0", style: TextStyle(color: AppColors.grey)),
            
            const SizedBox(height: 32),
            const Text(
              "At Bloomarina, we are committed to bringing the freshest groceries to your doorstep in minutes. Our mission is to simplify your life through technology and speed.",
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            
            const SizedBox(height: 32),
            _buildAboutRow(Icons.policy_outlined, "Privacy Policy"),
            _buildAboutRow(Icons.description_outlined, "Terms of Service"),
            _buildAboutRow(Icons.security_outlined, "Data Protection"),
            
            const SizedBox(height: 48),
            const Text("© 2026 Bloomarina Inc.", style: TextStyle(color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        onTap: () {},
      ),
    );
  }
}
