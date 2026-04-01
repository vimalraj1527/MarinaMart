import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/sticky_cart_bar.dart';
import 'home/home_view.dart';
import 'category/all_categories_view.dart';
import 'search/search_view.dart';
import 'user_info/profile_view.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _selectedIndex = 0;
  final CartController _cartController = Get.find<CartController>();

  final List<Widget> _pages = [
    const HomeView(),
    const AllCategoriesView(),
    const SearchView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          Positioned(
            left: 0, right: 0, bottom: 10,
            child: const StickyCartBar(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/cart'),
        backgroundColor: AppColors.primaryColor,
        elevation: 10,
        shape: const CircleBorder(),
        child: Obx(() => Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Lottie.network(
                'https://lottie.host/8123286f-c6b2-4d56-9e8c-859a8508a8f1/9pYV7c4v4C.json',
                width: 32,
                height: 32,
                errorBuilder: (c, e, s) => const Icon(Icons.shopping_basket_rounded, color: Colors.white),
              ),
            ),
            if (_cartController.cartItems.isNotEmpty)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    "${_cartController.totalItems}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        height: 70,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, "Home"),
              _buildNavItem(1, Icons.grid_view_rounded, "Categories"),
              const SizedBox(width: 40), // SPACE FOR FAB
              _buildNavItem(2, Icons.search_rounded, "Search"),
              _buildNavItem(3, Icons.person_rounded, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryColor : Colors.grey.shade400, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primaryColor : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
