import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Support")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSupportOption(Icons.headset_mic_outlined, "Talk to our Support Team", "Instant help", Colors.blue),
            _buildSupportOption(Icons.email_outlined, "Email Support", "Resolves within 24 hours", Colors.orange),
            _buildSupportOption(Icons.question_answer_outlined, "FAQs & Help Center", "Self-help resources", Colors.green),
            _buildSupportOption(Icons.chat_bubble_outline, "Chat with our Bot", "24/7 service", AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        onTap: () {},
      ),
    );
  }
}
