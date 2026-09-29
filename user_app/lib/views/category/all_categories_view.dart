import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/main_shell_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class AllCategoriesView extends StatefulWidget {
  const AllCategoriesView({super.key});

  @override
  State<AllCategoriesView> createState() => _AllCategoriesViewState();
}

class _AllCategoriesViewState extends State<AllCategoriesView> with TickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("All Categories", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 0.5)),
        backgroundColor: Colors.white.withOpacity(0.5),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 22),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.find<MainShellController>().changeTab(0);
            }
          },
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: 150, right: -50,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(math.sin(_floatController.value * 2 * math.pi) * 30, math.cos(_floatController.value * 2 * math.pi) * 30),
                  child: Container(
                    width: 250, height: 250, 
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
              if (controller.isLoading.value && controller.categories.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
              }
              
              final double screenWidth = MediaQuery.of(context).size.width;
              final int crossAxisCount = screenWidth > 600 ? 5 : (screenWidth > 450 ? 4 : 3);
              final double childAspectRatio = screenWidth < 350
                  ? 0.68
                  : (screenWidth < 380 ? 0.72 : 0.78);

              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                ),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final cat = controller.categories[index];
                  final color = _getCategoryColor(cat.name);
                  
                  return AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, math.sin((_floatController.value * 2 * math.pi) + (index * 0.5)) * 5),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/product-list', parameters: {'title': cat.name}),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: color.withOpacity(0.1), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 54, width: 54,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: cat.image.isNotEmpty 
                                ? Image.network(cat.image, fit: BoxFit.contain, errorBuilder: (c, e, s) => _getCategoryIcon(cat.name))
                                : _getCategoryIcon(cat.name),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                cat.name,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black87),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(String name) {
    IconData icon = Icons.shopping_bag_rounded;
    final n = name.toLowerCase();
    if (n.contains("fruit") || n.contains("veg")) {
      icon = Icons.apple_rounded;
    } else if (n.contains("milk") || n.contains("dairy")) icon = Icons.egg_rounded;
    else if (n.contains("drink") || n.contains("juice")) icon = Icons.local_drink_rounded;
    else if (n.contains("snack") || n.contains("munch")) icon = Icons.fastfood_rounded;
    else if (n.contains("clean")) icon = Icons.cleaning_services_rounded;
    else if (n.contains("meat")) icon = Icons.kebab_dining_rounded;
    return Icon(icon, size: 28, color: _getCategoryColor(name));
  }

  Color _getCategoryColor(String name) {
    final n = name.toLowerCase();
    if (n.contains("fruit") || n.contains("veg")) return const Color(0xFF4CAF50);
    if (n.contains("milk") || n.contains("dairy")) return const Color(0xFF2196F3);
    if (n.contains("drink") || n.contains("juice")) return const Color(0xFFFF9800);
    if (n.contains("snack") || n.contains("munch")) return const Color(0xFFE91E63);
    if (n.contains("clean")) return const Color(0xFF00BCD4);
    if (n.contains("meat")) return const Color(0xFFF44336);
    return AppColors.primaryColor;
  }
}
