import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../utils/app_colors.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Order Successful Animation
              Lottie.network(
                'https://lottie.host/17811ce7-3e11-424a-81a1-f761922c2a2b/8qC21e9C1C.json', // Premium tick animation
                height: 250,
                repeat: false,
                errorBuilder: (c,e,s) => const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 100),
              ),
              
              const SizedBox(height: 20),
              const Text(
                "Order Placed!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your order has been placed successfully and will be delivered shortly via Cash on Delivery.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.grey),
              ),
              
              const SizedBox(height: 40),
              
              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text("Keep Shopping", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Get.offNamed('/orders'),
                child: Text("View My Orders", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
