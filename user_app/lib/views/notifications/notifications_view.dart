import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_outlined, size: 80, color: AppColors.greyLight),
            const SizedBox(height: 16),
            const Text("Stay tuned!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("We'll let you know when we have updates for you."),
          ],
        ),
      ),
    );
  }
}
