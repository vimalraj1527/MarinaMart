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
import '../../controllers/home_controller.dart';

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
      body: CustomScrollView(
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
                    
                    const SizedBox(height: 140), // Spacing for docked bottom action sheet
                  ],
                ),
              ),
            ),
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
    final HomeController homeController = Get.find<HomeController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row containing Favorite Heart and Swiggy Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // Favorite Button
                Obx(() {
                  final isFav = homeController.isFavorite(product.id);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      homeController.toggleFavorite(product.id);
                      Get.snackbar(
                        isFav ? 'Removed' : 'Added to Favorites',
                        isFav ? '${product.name} removed from favorites.' : '${product.name} added to favorites.',
                        backgroundColor: isFav ? Colors.black87 : Colors.pinkAccent,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                        icon: const Icon(Icons.favorite_rounded, color: Colors.white),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: isFav ? Colors.pink.shade50 : Colors.grey.shade50,
                        border: Border.all(
                          color: isFav ? Colors.pink.shade100 : Colors.grey.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.pink : Colors.black54,
                        size: 24,
                      ),
                    ),
                  );
                }),
                const Spacer(),
                Obx(() {
                  int count = cartController.getItemCount(product.id);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44,
                    width: count == 0 ? 110 : 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: count == 0
                        ? Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                cartController.addToCart(product);
                              },
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "ADD",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Row(
                            key: const ValueKey('counter_btn'),
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  cartController.removeFromCart(product);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Icon(Icons.remove_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                              Text(
                                "$count",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  cartController.addToCart(product);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Icon(Icons.add_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                  );
                }),
              ],
            ),
          ),
          // Sticky Cart Bar (View Cart + Swiggy / Zepto free delivery tip)
          const StickyCartBar(),
          
          // Dynamic padding for bottom of screen depending on whether sticky cart is empty
          Obx(() {
            if (cartController.cartItems.isEmpty) {
              return SizedBox(height: MediaQuery.of(context).padding.bottom + 8);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
