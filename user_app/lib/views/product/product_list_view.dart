import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/add_to_cart_button.dart';
import '../../widgets/sticky_cart_bar.dart';
import '../../controllers/product_list_controller.dart';

class ProductListView extends StatefulWidget {
  final String title;
  final List<Product>? products;

  const ProductListView({super.key, required this.title, this.products});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> with TickerProviderStateMixin {
  late ProductListController _controller;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _controller = Get.put(ProductListController());
    
    if (widget.products == null || widget.products!.isEmpty) {
      final categoryTitle = Get.parameters['title'] ?? widget.title;
      _controller.fetchProductsByCategory(categoryTitle);
    } else {
      _controller.categoryProducts.assignAll(widget.products!);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String displayTitle = Get.parameters['title'] ?? widget.title;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black87, letterSpacing: 0.5)),
        backgroundColor: Colors.white.withOpacity(0.5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 22),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      bottomNavigationBar: const StickyCartBar(),
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: 200, left: -50,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(math.sin(_floatController.value * 2 * math.pi) * 30, math.cos(_floatController.value * 2 * math.pi) * 30),
                  child: Container(
                    width: 300, height: 300, 
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
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
              }
              
              if (_controller.categoryProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
                        child: const Icon(Icons.inventory_2_rounded, size: 60, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 20),
                      const Text("No products found here.", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58, // Safely handles flexible sizes
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _controller.categoryProducts.length,
                itemBuilder: (context, index) {
                  final product = _controller.categoryProducts[index];
                  return AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, math.sin((_floatController.value * 2 * math.pi) + index) * 3),
                        child: child,
                      );
                    },
                    child: _buildProductCard(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product-details', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4F8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: Image.network(product.image, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.shopping_bag_rounded, color: Colors.grey, size: 40)),
                    ),
                  ),
                  Positioned(
                    top: 0, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF8C00).withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, color: Colors.white, size: 10),
                          Text("12 MINS", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(product.unit, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("₹${product.price}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: AddToCartButton(product: product),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
