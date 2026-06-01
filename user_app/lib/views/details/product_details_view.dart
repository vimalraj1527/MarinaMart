import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product_model.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import 'package:flutter/services.dart';
import '../../widgets/sticky_cart_bar.dart';
import '../../widgets/add_to_cart_button.dart';

class ProductDetailsView extends StatelessWidget {
  final Product product;
  final String heroTag;
  final CartController cartController = Get.find();

  ProductDetailsView({super.key})
      : product = Get.arguments is Map ? (Get.arguments as Map)['product'] as Product : Get.arguments as Product,
        heroTag = Get.arguments is Map ? (Get.arguments as Map)['heroTag'] as String : 'product_${(Get.arguments as Product).id}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fast Delivery Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined, color: AppColors.primaryColor, size: 16),
                              SizedBox(width: 6),
                              Text("Standard Delivery (Fast on ₹1000+)", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w800, fontSize: 12)),
                            ],
                          ),
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "₹${product.price}",
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.unit,
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: Colors.black12, thickness: 1),
                        ),
                        
                        const Text(
                          "Product Details",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Text(
                            product.description ?? "Experience the best quality freshness delivered right to your doorstep. This item is carefully handled and packed to ensure maximum freshness and quality.",
                            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.6, fontWeight: FontWeight.w500),
                          ),
                        ),
                        
                        const SizedBox(height: 250), // Extra space for sticky bars
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 110,
            child: const StickyCartBar(),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 420,
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: heroTag,
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(colors: [Colors.white, Color(0xFFF0F4F8)], radius: 1.5),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag_rounded, size: 100, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade200, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.favorite_border_rounded, color: Colors.black54, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                int count = cartController.getItemCount(product.id);
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: count == 0
                      ? Builder(
                          builder: (btnCtx) => ElevatedButton(
                            key: const ValueKey('add_btn'),
                            onPressed: () {
                              final renderBox = btnCtx.findRenderObject() as RenderBox?;
                              if (renderBox != null) {
                                triggerMeteorDropCartAnimation(context, product, cartController, renderBox);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 3,
                              shadowColor: AppColors.primaryColor.withOpacity(0.35),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 22),
                                SizedBox(width: 10),
                                Text("Add to Cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey('counter_btn'),
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primaryColor, Color(0xFF6C5CE7)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_rounded, color: Colors.white, size: 28),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  cartController.removeFromCart(product);
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  "$count",
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ),
                              Builder(
                                builder: (addCtx) => IconButton(
                                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                                  onPressed: () {
                                    final renderBox = addCtx.findRenderObject() as RenderBox?;
                                    if (renderBox != null) {
                                      triggerMeteorDropCartAnimation(context, product, cartController, renderBox);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
