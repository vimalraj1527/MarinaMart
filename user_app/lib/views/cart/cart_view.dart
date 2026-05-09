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

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.primaryColor.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 24),
                  const Text("Your cart is empty", style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text("Add items to start building your basket.", style: TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: controller.cartItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 70, height: 70,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.network(
                              item.product.image,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(item.product.unit, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(child: Text("₹${item.product.price}", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildQuantityButton(Icons.remove, () => controller.removeFromCart(item.product)),
                                          Container(
                                            constraints: const BoxConstraints(minWidth: 28),
                                            alignment: Alignment.center,
                                            child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
                                          ),
                                          _buildQuantityButton(Icons.add, () => controller.addToCart(item.product)),
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
                    );
                  },
                ),
              ),
              _buildCheckoutSection(controller),
            ],
          );
        }),
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
        width: 32,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildCheckoutSection(CartController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Text("Total Payable", style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
                 Flexible(
                   child: Text("₹${controller.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87), overflow: TextOverflow.ellipsis, maxLines: 1),
                 ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                   if (!controller.isLoading.value) Get.toNamed('/checkout');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Proceed to Checkout", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
