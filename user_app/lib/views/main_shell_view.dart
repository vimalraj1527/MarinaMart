import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_colors.dart';
import 'home/home_view.dart';
import 'category/all_categories_view.dart';
import 'search/search_view.dart';
import 'user_info/profile_view.dart';
import '../widgets/sticky_cart_bar.dart';

import '../controllers/main_shell_controller.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView>
    with TickerProviderStateMixin {
  final CartController _cartController = Get.find<CartController>();
  final MainShellController _shellController = Get.find<MainShellController>();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const HomeView(),
    const AllCategoriesView(),
    const SearchView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasItems = _cartController.cartItems.isNotEmpty;
      return Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: hasItems ? 110.0 : 0.0),
              child: IndexedStack(
                index: _shellController.selectedIndex.value,
                children: _pages,
              ),
            ),
            if (hasItems)
              const Positioned(
                bottom: 0, // Position directly above BottomAppBar
                left: 0,
                right: 0,
                child: StickyCartBar(isFloating: true),
              ),
          ],
        ),
        floatingActionButton: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () => Get.toNamed('/cart'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    highlightElevation: 0,
                    shape: const CircleBorder(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Lottie.network(
                            'https://lottie.host/8123286f-c6b2-4d56-9e8c-859a8508a8f1/9pYV7c4v4C.json',
                            width: 32,
                            height: 32,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.shopping_basket_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
    });
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _shellController.selectedIndex.value == index;
    return GestureDetector(
      onTap: () => _shellController.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
