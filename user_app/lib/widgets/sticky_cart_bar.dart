import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_colors.dart';

class StickyCartBar extends StatefulWidget {
  final bool isFloating;
  const StickyCartBar({super.key, this.isFloating = false});

  @override
  State<StickyCartBar> createState() => _StickyCartBarState();
}

class _StickyCartBarState extends State<StickyCartBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
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

      final double subtotal = cartController.totalAmount;
      final double remaining = 501.0 - subtotal;
      final double progress = (subtotal / 501.0).clamp(0.0, 1.0);

      Widget content = Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, widget.isFloating ? 4 : 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Free Delivery Hint strip & Progress Track (Swiggy / Zepto style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5), // Light emerald green
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.delivery_dining_rounded,
                        color: Color(0xFF059669),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          remaining > 0
                              ? "Add ₹${remaining.toStringAsFixed(0)} more for FREE Scheduled Delivery"
                              : "Eligible for FREE Scheduled Delivery!",
                          style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFD1FAE5), // Duller track background
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)), // Active emerald indicator
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Proceed to Checkout / View Cart Button
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed('/cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 3,
                        shadowColor: AppColors.primaryColor.withValues(alpha: 0.35),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: small size value & items count
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${cartController.totalItems} ITEM${cartController.totalItems > 1 ? 'S' : ''}",
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                "₹${cartController.totalAmount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          // Right side: View Cart action text
                          const Row(
                            children: [
                               Text(
                                "View Cart",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_right_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );

      if (widget.isFloating) {
        return content;
      } else {
        return SafeArea(
          top: false,
          child: content,
        );
      }
    });
  }
}
