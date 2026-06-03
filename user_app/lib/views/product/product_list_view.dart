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
import '../../controllers/home_controller.dart';

class ProductListView extends StatefulWidget {
  final String title;
  final List<Product>? products;

  const ProductListView({super.key, required this.title, this.products});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> with TickerProviderStateMixin {
  late ProductListController _controller;
  late HomeController _homeController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ProductListController>()) {
      Get.delete<ProductListController>();
    }
    _controller = Get.put(ProductListController());
    _homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    final categoryTitle = Get.parameters['title'] ?? widget.title;
    _controller.selectedCategory.value = categoryTitle;

    final args = Get.arguments;
    if (args is List<Product> && args.isNotEmpty) {
      _controller.categoryProducts.assignAll(args);
    } else if (args is List && args.isNotEmpty && args.first is Product) {
      _controller.categoryProducts.assignAll(args.cast<Product>());
    } else if (widget.products != null && widget.products!.isNotEmpty) {
      _controller.categoryProducts.assignAll(widget.products!);
    } else {
      _controller.fetchProductsByCategory(categoryTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Obx(() => Text(
              _controller.selectedCategory.value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            )),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      bottomNavigationBar: const StickyCartBar(),
      body: Row(
        children: [
          _buildLeftSidebar(_homeController),
          _buildRightProducts(),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(HomeController homeController) {
    return Container(
      width: 85,
      color: const Color(0xFFF4F6F8),
      child: Obx(() {
        final categories = homeController.categories;
        return ListView.builder(
          itemCount: categories.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Obx(() {
              final isSelected = _controller.selectedCategory.value.trim().toLowerCase() == cat.name.trim().toLowerCase();
              print("Sidebar Item: ${cat.name} | isSelected: $isSelected | Active: ${_controller.selectedCategory.value}");
              return GestureDetector(
                key: ValueKey("sidebar_${cat.id}"),
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  print("Switching category to: ${cat.name}");
                  _controller.fetchProductsByCategory(cat.name);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0x00FFFFFF),
                    border: isSelected
                        ? Border(
                            left: BorderSide(
                              color: AppColors.primaryColor,
                              width: 3.5,
                            ),
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category icon/image
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.08)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: cat.image.isNotEmpty
                            ? Image.network(
                                cat.image,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => _getCategoryIcon(cat.name, isSelected),
                              )
                            : _getCategoryIcon(cat.name, isSelected),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildRightProducts() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Obx(() {
          final showLoader = _controller.isLoading.value && _controller.categoryProducts.isEmpty;

          if (showLoader) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (_controller.categoryProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.inventory_2_rounded, size: 48, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "No products found here.",
                      style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                    child: Text(
                      "${_controller.categoryProducts.length} Items Available",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Opacity(
                      opacity: _controller.isLoading.value ? 0.6 : 1.0,
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.52,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _controller.categoryProducts.length,
                        itemBuilder: (context, index) {
                          final product = _controller.categoryProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (_controller.isLoading.value)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product-details', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 90,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag_rounded, color: Colors.grey, size: 32),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0, left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, color: Colors.white, size: 8),
                          Text("STANDARD", style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, height: 1.2, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.unit,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${product.price}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
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

  Widget _getCategoryIcon(String name, bool isSelected) {
    IconData icon = Icons.shopping_bag_rounded;
    final n = name.toLowerCase();
    if (n.contains("fruit") || n.contains("veg")) {
      icon = Icons.apple_rounded;
    } else if (n.contains("milk") || n.contains("dairy")) {
      icon = Icons.egg_rounded;
    } else if (n.contains("drink") || n.contains("juice")) {
      icon = Icons.local_drink_rounded;
    } else if (n.contains("snack") || n.contains("munch")) {
      icon = Icons.fastfood_rounded;
    } else if (n.contains("clean")) {
      icon = Icons.cleaning_services_rounded;
    } else if (n.contains("meat")) {
      icon = Icons.kebab_dining_rounded;
    }

    return Icon(
      icon,
      size: 20,
      color: isSelected ? AppColors.primaryColor : Colors.black45,
    );
  }
}
