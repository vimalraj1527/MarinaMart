import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../models/product_model.dart';
import '../../widgets/add_to_cart_button.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _currentBanner++;
        if (_currentBanner > 2) _currentBanner = 0;
        _bannerController.animateToPage(
          _currentBanner, 
          duration: const Duration(milliseconds: 600), 
          curve: Curves.easeInOut
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final LocationController locationController = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTicker(),
                _buildAppBar(locationController),
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchHomeData(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBanners(controller),
                          _buildCategories(controller),
                          _buildSectionHeader("Trending Near You", onSeeAll: () => Get.toNamed('/product-list', arguments: controller.products, parameters: {'title': 'Trending Near You'})),
                          _buildHorizontalProducts(controller),
                          _buildSectionHeader("Popular Items", onSeeAll: () => Get.toNamed('/product-list', arguments: controller.products, parameters: {'title': 'Popular Items'})),
                          _buildProductGrid(controller),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicker() {
    final settings = Get.find<SettingsController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.yellow.shade700,
      child: Obx(() => Center(
        child: Text(
          "🚚 FREE DELIVERY ON ALL ORDERS ABOVE ₹${settings.freeDeliveryThreshold.value.toInt()}!",
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      )),
    );
  }

  Widget _buildAppBar(LocationController locationController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showLocationDialog(locationController),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Delivery in 12 Mins", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                  Row(
                    children: [
                      Obx(() => Text(
                        locationController.shortAddress.value,
                        style: const TextStyle(fontSize: 12, color: AppColors.grey),
                        overflow: TextOverflow.ellipsis,
                      )),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/profile'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
              child: const Icon(Icons.person_outline_rounded, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 5),
      child: GestureDetector(
        onTap: () => Get.toNamed('/search'),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primaryColor),
              SizedBox(width: 12),
              Text("Search \"milk\", \"eggs\", \"bread\"", style: TextStyle(color: AppColors.grey, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanners(HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.banners.isEmpty) {
        return _buildShimmer(height: 180, width: double.infinity);
      }
      return SizedBox(
        height: 180,
        child: PageView(
          controller: _bannerController,
          onPageChanged: (idx) => _currentBanner = idx,
          children: [
            _buildSingleBanner(
              const Color(0xFF00B894), 
              "Fresh Delivery\nEVERYDAY", 
              "https://assets9.lottiefiles.com/packages/lf20_76m8m1.json"
            ),
            _buildSingleBanner(
              const Color(0xFF6C5CE7), 
              "MEGA SAVINGS\non Snacking", 
              "https://assets4.lottiefiles.com/packages/lf20_m6cuL6.json"
            ),
            _buildSingleBanner(
              const Color(0xFFE17055), 
              "Summer Fruits\nUp to 30% OFF", 
              "https://assets10.lottiefiles.com/packages/lf20_rc63p8u1.json"
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSingleBanner(Color color, String title, String lottieUrl) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10, bottom: -10, top: -10,
            child: Lottie.network(lottieUrl, width: 120, errorBuilder: (c, e, s) => const Icon(Icons.flash_on, size: 50, color: Colors.white)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.1)),
              const SizedBox(height: 10),
              const Text("Limited Time Offer", style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Shop by Category", onSeeAll: () => Get.toNamed('/all-categories')),
        Obx(() {
          if (controller.isLoading.value && controller.categories.isEmpty) {
            return _buildCategoryGridShimmer();
          }
          
          return SizedBox(
            height: 220, // Height to fit 2 rows of items
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 ROWS
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                final color = _getCategoryColor(cat.name);
                return GestureDetector(
                  onTap: () {
                    final catName = cat.name.toLowerCase();
                    final catProducts = controller.products.where((p) {
                      final pCat = p.category.toLowerCase();
                      // Expanded match to handle 'Dairy' vs 'Diary' or 'Fruits' vs 'Fruit & Veg'
                      bool isDairyMatch = (catName.contains("dairy") || catName.contains("diary")) && (pCat.contains("dairy") || pCat.contains("diary"));
                      return isDairyMatch || pCat.contains(catName) || catName.contains(pCat);
                    }).toList();
                    Get.toNamed('/product-list', arguments: catProducts, parameters: {'title': cat.name});
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 75, width: 75,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                          border: Border.all(color: color.withOpacity(0.05), width: 1),
                        ),
                        child: cat.image.isNotEmpty 
                          ? Image.network(cat.image, fit: BoxFit.contain, errorBuilder: (c,e,s) => _getCategoryIcon(cat.name))
                          : _getCategoryIcon(cat.name),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _getCategoryIcon(String name) {
    IconData icon = Icons.shopping_bag_outlined;
    final n = name.toLowerCase();
    if (n.contains("fruit") || n.contains("veg")) icon = Icons.apple_rounded;
    else if (n.contains("milk") || n.contains("dairy")) icon = Icons.egg_rounded;
    else if (n.contains("drink") || n.contains("juice")) icon = Icons.local_drink_rounded;
    else if (n.contains("snack") || n.contains("munch")) icon = Icons.fastfood_rounded;
    
    return Icon(icon, size: 30, color: _getCategoryColor(name));
  }

  Color _getCategoryColor(String name) {
    final n = name.toLowerCase();
    if (n.contains("fruit") || n.contains("veg")) return Colors.green;
    if (n.contains("milk") || n.contains("dairy")) return Colors.blue;
    if (n.contains("drink") || n.contains("juice")) return Colors.orange;
    if (n.contains("snack") || n.contains("munch")) return Colors.red;
    if (n.contains("clean")) return Colors.cyan;
    return AppColors.primaryColor;
  }

  Widget _buildCategoryGridShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 220,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.15,
          ),
          itemCount: 8,
          itemBuilder: (context, index) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22))),
        ),
      ),
    );
  }

  Widget _buildHorizontalProducts(HomeController controller) {
    return SizedBox(
      height: 230,
      child: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) return const SizedBox();
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          itemCount: controller.products.length,
          itemBuilder: (context, index) => Container(
            width: 160,
            margin: const EdgeInsets.only(right: 15),
            child: _buildProductCard(controller.products[index]),
          ),
        );
      }),
    );
  }

  Widget _buildProductGrid(HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) return const SizedBox();
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 15, mainAxisSpacing: 15,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) => _buildProductCard(controller.products[index]),
      );
    });
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product-details', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
                child: Image.network(product.image, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.shopping_bag_outlined)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product.unit, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("₹${product.price}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                      AddToCartButton(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.defaultPadding, 24, AppConstants.defaultPadding, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text("See all", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }


  Widget _buildShimmer({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!, highlightColor: Colors.grey[100]!,
      child: Container(height: height, width: width, margin: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
    );
  }

  void _showLocationDialog(LocationController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Delivery Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 10),
            _buildBottomSheetItem(
              Icons.my_location, "Current Location", controller.currentAddress.value, 
              () { controller.setActiveAddress("current", controller.currentAddress.value); Get.back(); }
            ),
            const Divider(),
            ...controller.savedAddresses.map((addr) => _buildBottomSheetItem(
              Icons.home_outlined, addr['title']!, addr['address']!,
              () { controller.setActiveAddress(addr['id']!, addr['address']!); Get.back(); }
            )).toList(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { Get.back(); Get.toNamed('/addresses'); },
                icon: const Icon(Icons.add),
                label: const Text("Manage Addresses"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomSheetItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }
}
