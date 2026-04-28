import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> with TickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        backgroundColor: Colors.white.withOpacity(0.5),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: 100, left: -50,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(math.sin(_floatController.value * 2 * math.pi) * 30, math.cos(_floatController.value * 2 * math.pi) * 30),
                  child: Container(
                    width: 250, height: 250, 
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryColor.withOpacity(0.12)),
                  ),
                );
              }
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),
          
          SafeArea(
            child: Obx(() {
              if (controller.cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                        child: const Icon(Icons.remove_shopping_cart_rounded, size: 80, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 24),
                      const Text("Your cart is empty", style: TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      const Text("Looks like you haven't added anything yet.", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 20),
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.cartItems[index];
                        return AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, math.sin((_floatController.value * 2 * math.pi) + index) * 3),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 90, height: 90,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F4F8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Image.network(
                                    item.product.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag_rounded, size: 40, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(item.product.unit, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 14),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Flexible(child: Text("₹${item.product.price}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black), overflow: TextOverflow.ellipsis)),
                                          const SizedBox(width: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(color: Colors.grey.shade200, width: 2),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _buildQuantityButton(Icons.remove_rounded, () => controller.removeFromCart(item.product)),
                                                Container(
                                                  constraints: const BoxConstraints(minWidth: 32),
                                                  alignment: Alignment.center,
                                                  child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                                ),
                                                _buildQuantityButton(Icons.add_rounded, () => controller.addToCart(item.product)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildCheckoutSection(controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 20),
      ),
    );
  }

  Widget _buildCheckoutSection(CartController controller) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: const Border(top: BorderSide(color: Colors.white, width: 2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, -10))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   const Text("Grand Total", style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                   Flexible(
                     child: Text("₹${controller.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF10B981)), overflow: TextOverflow.ellipsis, maxLines: 1),
                   ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                   if (!controller.isLoading.value) Get.toNamed('/checkout');
                },
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF203A43).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("PROCEED TO CHECKOUT", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      if (!controller.isLoading.value) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
