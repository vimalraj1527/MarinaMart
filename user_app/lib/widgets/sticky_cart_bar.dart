import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_colors.dart';
import 'dart:math' as math;

class StickyCartBar extends StatefulWidget {
  const StickyCartBar({super.key});

  @override
  State<StickyCartBar> createState() => _StickyCartBarState();
}

class _StickyCartBarState extends State<StickyCartBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Obx(() {
      if (cartController.cartItems.isEmpty) return const SizedBox.shrink();

      return SafeArea(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 15), 
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)], // Ultra premium dark mode pill
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(40), // Perfect pill shape
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3 + (_pulseController.value * 0.2)), // Pulsing aura
                    blurRadius: 15 + (_pulseController.value * 10), 
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.toNamed('/cart'),
                  borderRadius: BorderRadius.circular(40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: const Color(0xFFFF8C00).withOpacity(0.5), blurRadius: 8)],
                              ),
                              child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${cartController.totalItems} ITEMS",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "₹${cartController.totalAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 17, fontWeight: FontWeight.w900), // Emerald green price
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("VIEW CART", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      );
    });
  }
}
