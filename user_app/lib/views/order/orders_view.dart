import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.greyLight),
            const SizedBox(height: 16),
            const Text("No active orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Your previous orders will appear here"),
          ],
        ),
      ),
    );
  }
}
