import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/location_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../models/product_model.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section (Address)
            _buildAppBar(),
            
            // Search Bar (Sticky-like)
            _buildSearchBar(),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchHomeData(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner/Carousel
                      _buildBanners(controller),

                      // Browse by Category
                      _buildCategories(controller),

                      // Popular Products
                      _buildPopularProducts(controller),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    final LocationController locationController = Get.find<LocationController>();
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: GestureDetector(
        onTap: () => _showLocationDialog(locationController),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on, color: AppColors.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Delivery at",
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => Text(
                          locationController.shortAddress.value,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        )),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/profile'),
              child: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.person_outline, color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationDialog(LocationController controller) {
    final TextEditingController textController = TextEditingController(text: controller.currentAddress.value);
    
    Get.dialog(
      AlertDialog(
        title: const Text("Change Delivery Address"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: "Enter your address",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                controller.getCurrentLocation();
              },
              icon: const Icon(Icons.my_location),
              label: const Text("Use Current Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              controller.updateAddressManual(textController.text);
              Get.back();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: "Search for eggs, milk, meat...",
            prefixIcon: Icon(Icons.search, color: AppColors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBanners(HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.banners.isEmpty) {
        return Container(
          height: 180,
          margin: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      
      // If no banners, show a placeholder greeting
      if (controller.banners.isEmpty) {
        return Container(
          height: 180,
          width: double.infinity,
          margin: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade300, Colors.orange.shade700],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20, bottom: -20,
                child: Icon(Icons.flash_on, size: 150, color: Colors.white.withOpacity(0.2)),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Flash Sale!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("Get up to 50% off on fresh items", style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              )
            ],
          ),
        );
      }
      
      // Real banners implementation would go here with PageView
      return const SizedBox();
    });
  }

  Widget _buildCategories(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          child: Text(
            "Shop by Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: controller.categories.isEmpty ? 6 : controller.categories.length,
            itemBuilder: (context, index) {
              final cat = controller.categories.isEmpty ? null : controller.categories[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: cat != null && cat.image.isNotEmpty 
                        ? Image.network(cat.image, fit: BoxFit.cover)
                        : _getCategoryIcon(cat?.name),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat?.name ?? "Loading...",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          )),
        ),
      ],
    );
  }

  Widget _getCategoryIcon(String? name) {
    IconData iconData = Icons.shopping_bag_outlined;
    Color color = AppColors.primaryColor;

    if (name == null) return Icon(iconData, color: color);

    final n = name.toLowerCase();
    if (n.contains("fruit") || n.contains("veg")) {
      iconData = Icons.apple;
      color = Colors.green;
    } else if (n.contains("dairy") || n.contains("bread") || n.contains("egg")) {
      iconData = Icons.egg_outlined;
      color = Colors.orange;
    } else if (n.contains("munch") || n.contains("chips")) {
      iconData = Icons.fastfood_outlined;
      color = Colors.redAccent;
    } else if (n.contains("drink") || n.contains("juice")) {
      iconData = Icons.local_drink_outlined;
      color = Colors.blue;
    } else if (n.contains("tea") || n.contains("coffee")) {
      iconData = Icons.coffee_outlined;
      color = Colors.brown;
    } else if (n.contains("atta") || n.contains("rice") || n.contains("dal")) {
      iconData = Icons.eco_outlined;
      color = Colors.amber;
    } else if (n.contains("chicken") || n.contains("meat") || n.contains("fish")) {
      iconData = Icons.restaurant_outlined;
      color = Colors.red;
    } else if (n.contains("clean")) {
      iconData = Icons.cleaning_services_outlined;
      color = Colors.cyan;
    } else if (n.contains("personal")) {
      iconData = Icons.face_retouching_natural_outlined;
      color = Colors.pinkAccent;
    } else if (n.contains("baby")) {
      iconData = Icons.child_care_outlined;
      color = Colors.deepPurpleAccent;
    } else if (n.contains("pet")) {
      iconData = Icons.pets_outlined;
      color = Colors.brown.shade300;
    }

    return Icon(iconData, color: color, size: 30);
  }

  Widget _buildPopularProducts(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(AppConstants.defaultPadding, 24, AppConstants.defaultPadding, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Popular Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "See all",
                style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: controller.products.isEmpty ? 4 : controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products.isEmpty ? null : controller.products[index];
            return _buildProductCard(product);
          },
        )),
      ],
    );
  }

  Widget _buildProductCard(Product? product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: product != null && product.image.isNotEmpty
                  ? Image.network(product.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50, color: AppColors.greyLight))
                  : const Icon(Icons.image, size: 50, color: AppColors.greyLight),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? "Fresh Product", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(product?.unit ?? "500g", style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${product?.price.toStringAsFixed(0) ?? '0'}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryColor)
                    ),
                    const AddToCartButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: GNav(
        rippleColor: AppColors.primaryColor.withOpacity(0.1),
        hoverColor: AppColors.primaryColor.withOpacity(0.1),
        gap: 8,
        activeColor: AppColors.primaryColor,
        iconSize: 24,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: const Duration(milliseconds: 400),
        tabBackgroundColor: AppColors.primaryColor.withOpacity(0.1),
        color: AppColors.grey,
        tabs: const [
          GButton(icon: Icons.home_filled, text: 'Home'),
          GButton(icon: Icons.category_outlined, text: 'Categories'),
          GButton(icon: Icons.shopping_cart_outlined, text: 'Cart'),
          GButton(icon: Icons.person_outline, text: 'Account'),
        ],
        selectedIndex: 0,
        onTabChange: (index) {
          // Handle tab change
        },
      ),
    );
  }
}

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("ADD", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 10)),
          SizedBox(width: 2),
          Icon(Icons.add, color: AppColors.primaryColor, size: 14),
        ],
      ),
    );
  }
}
