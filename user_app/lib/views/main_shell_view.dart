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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/cart'),
        backgroundColor: AppColors.primaryColor,
        elevation: 8,
        shape: const CircleBorder(),
        child: Obx(() => Stack(
          alignment: Alignment.center,
          children: [
            Lottie.network('https://lottie.host/8123286f-c6b2-4d56-9e8c-859a8508a8f1/9pYV7c4v4C.json', width: 30, height: 30, errorBuilder: (c,e,s) => const Icon(Icons.shopping_basket_rounded, color: Colors.white)),
            if (_cartController.cartItems.isNotEmpty)
              Positioned(
                right: -4, top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text("${_cartController.totalItems}", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StickyCartBar(),
            Container(
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
          ],
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
