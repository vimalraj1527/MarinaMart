import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product_model.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

import 'package:flutter/services.dart';

import '../../widgets/sticky_cart_bar.dart';

class ProductDetailsView extends StatelessWidget {
  final Product product = Get.arguments;
  final CartController cartController = Get.find();

  ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "₹${product.price}",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.unit,
                        style: const TextStyle(fontSize: 16, color: AppColors.grey),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Product Description",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description ?? "No description available for this product.",
                        style: const TextStyle(fontSize: 15, color: AppColors.grey, height: 1.5),
                      ),
                      const SizedBox(height: 120), // Extra space for sticky bars
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 95,
            child: StickyCartBar(),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: product.id,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(40),
            child: Image.network(
              product.image,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.image, size: 100, color: AppColors.greyLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyLight),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.favorite_border),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                int count = cartController.getItemCount(product.id);
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: count == 0
                      ? ElevatedButton(
                          key: const ValueKey('add_btn'),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            cartController.addToCart(product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: const Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        )
                      : Container(
                          key: const ValueKey('counter_btn'),
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  cartController.removeFromCart(product);
                                },
                              ),
                              Text(
                                "$count",
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  cartController.addToCart(product);
                                },
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
