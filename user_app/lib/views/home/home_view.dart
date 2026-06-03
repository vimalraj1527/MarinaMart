import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../models/product_model.dart';
import '../../widgets/add_to_cart_button.dart';
import '../../widgets/birthday_greeting_overlay.dart';
import '../../widgets/live_order_tracker.dart';
import '../../services/storage_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _timer;
  bool _showBirthdayOverlay = false;

  late AnimationController _floatController;
  late AnimationController _pulseController;

  Timer? _searchTickerTimer;
  int _currentKeywordIndex = 0;
  final List<String> _searchKeywords = [
    'fresh milk & bread',
    'farm fresh eggs',
    'tender coconut water',
    'crispy potato chips',
    'juicy alphonso mangoes',
    'chilled soft drinks',
    'premium chocolates',
    'paneer & curd',
    'organic vegetables',
    'cleaning essentials',
  ];

  @override
  void initState() {
    super.initState();

    // Liquid Floating Animation for Categories
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Heartbeat Pulse Animation for Search Bar
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _currentBanner++;
        if (_currentBanner > 2) _currentBanner = 0;
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.elasticOut,
        );
      }
    });

    _searchTickerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentKeywordIndex =
              (_currentKeywordIndex + 1) % _searchKeywords.length;
        });
      }
    });

    // Check birthday and show greeting after a short delay (limit to once per hour, bypass in debug mode)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final authController = Get.find<AuthController>();
      if (authController.isBirthdayToday) {
        final storage = Get.find<StorageService>();
        final lastShown = storage.getLastBirthdayGreetingTime();
        final now = DateTime.now().millisecondsSinceEpoch;
        
        if (kDebugMode || lastShown == null || (now - lastShown) >= 3600000) {
          setState(() => _showBirthdayOverlay = true);
          storage.setLastBirthdayGreetingTime(now);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchTickerTimer?.cancel();
    _bannerController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final LocationController locationController =
        Get.find<LocationController>();
    // Ensure OrdersController is registered so LiveOrderTracker can find it
    if (!Get.isRegistered<OrdersController>()) Get.put(OrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Top Brand Header Background Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Obx(() {
              final activeTheme = ThemeController.to.currentTheme;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activeTheme.primaryColor.withOpacity(0.15),
                      activeTheme.primaryColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              );
            }),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTicker(),
                _buildAppBar(locationController),
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryColor,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await controller.fetchHomeData();
                      await Get.find<SettingsController>()
                          .fetchRemoteSettings();
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildBanners(controller),
                          _buildCategories(controller),
                          _buildSectionHeader(
                            "Trending Near You",
                            onSeeAll: () => Get.toNamed(
                              '/product-list',
                              arguments: controller.products,
                              parameters: {'title': 'Trending Near You'},
                            ),
                            icon: Icons.local_fire_department_rounded,
                          ),
                          _buildHorizontalProducts(controller),
                          _buildSectionHeader(
                            "Popular Items",
                            onSeeAll: () => Get.toNamed(
                              '/product-list',
                              arguments: controller.products,
                              parameters: {'title': 'Popular Items'},
                            ),
                            icon: Icons.star_rounded,
                          ),
                          _buildProductGrid(controller),
                          const SizedBox(height: 250),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Birthday Greeting Overlay ─────────────────────────────────────
          if (_showBirthdayOverlay)
            Positioned.fill(
              child: BirthdayGreetingOverlay(
                userName:
                    Get.find<AuthController>().currentUser['name']
                        ?.toString() ??
                    'Friend',
                onClose: () => setState(() => _showBirthdayOverlay = false),
              ),
            ),

          // ── Live order tracker sticky bottom bar ─────────────────────────
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LiveOrderTrackerBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTicker() {
    final settings = Get.find<SettingsController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111), // Deep contrasting black
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Shimmer.fromColors(
          baseColor: const Color(0xFFFFD700), // Rich Gold
          highlightColor: Colors.white, // Sparkling White
          period: const Duration(milliseconds: 2500),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "FREE DELIVERY ON ORDERS ABOVE ₹${settings.freeDeliveryThreshold.value.toInt()}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.local_shipping_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(LocationController locationController) {
    final storage = Get.find<StorageService>();
    final userStr = storage.getUser();
    String firstLetter = 'U';
    if (userStr != null) {
      try {
        final user = jsonDecode(userStr);
        final name = user['name']?.toString() ?? 'U';
        if (name.isNotEmpty) firstLetter = name[0].toUpperCase();
      } catch (e) {}
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        16,
        AppConstants.defaultPadding,
        10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() {
            final activeTheme = ThemeController.to.currentTheme;
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activeTheme.primaryColor,
                    activeTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: activeTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 24,
              ),
            );
          }),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => _showLocationDialog(locationController),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Obx(() {
                     final activeTheme = ThemeController.to.currentTheme;
                     return Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         const Text(
                           "MaRina",
                           style: TextStyle(
                             fontWeight: FontWeight.w900,
                             fontSize: 18,
                             color: Colors.black87,
                             letterSpacing: -0.5,
                             fontFamily: 'Outfit',
                           ),
                         ),
                         Text(
                           "MaRt",
                           style: TextStyle(
                             fontWeight: FontWeight.w900,
                             fontSize: 18,
                             color: activeTheme.primaryColor,
                             letterSpacing: -0.5,
                             fontFamily: 'Outfit',
                           ),
                         ),
                       ],
                     );
                   }),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Obx(
                          () => Text(
                            locationController.shortAddress.value,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Obx(() {
                        final activeTheme = ThemeController.to.currentTheme;
                        return Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: activeTheme.primaryColor,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            final activeTheme = ThemeController.to.currentTheme;
            return GestureDetector(
              onLongPress: () {
                if (locationController.currentPosition.value != null) {
                  Get.find<SettingsController>().syncStoreToCurrentLocation(
                    locationController.currentPosition.value!.latitude,
                    locationController.currentPosition.value!.longitude,
                  );
                }
              },
              onTap: () => Get.toNamed('/profile'),
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activeTheme.primaryColor,
                      activeTheme.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: activeTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        5,
        AppConstants.defaultPadding,
        15,
      ),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Ultra rounded capsule
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(
                  0.2 + (_pulseController.value * 0.3),
                ),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(
                    0.05 + (_pulseController.value * 0.1),
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/search'),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.toNamed('/search'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Search",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        ClipRect(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutQuad,
                            switchOutCurve: Curves.easeInQuad,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 1.2),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                            child: Text(
                              _searchKeywords[_currentKeywordIndex],
                              key: ValueKey<String>(
                                _searchKeywords[_currentKeywordIndex],
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      Get.toNamed('/search', arguments: {'triggerVoice': true}),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: AppColors.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBanners(HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.banners.isEmpty) {
        return _buildShimmer(height: 165, width: double.infinity);
      }
      return SizedBox(
        height: 165,
        child: PageView(
          controller: _bannerController,
          onPageChanged: (idx) => _currentBanner = idx,
          children: controller.banners.isNotEmpty
              ? controller.banners.map<Widget>((b) {
                  return _buildSingleBanner(
                    Color(
                      int.tryParse(b['color'] ?? '0xFF00B894') ?? 0xFF00B894,
                    ),
                    b['title'] ?? '',
                    b['lottieUrl'] ??
                        'https://assets9.lottiefiles.com/packages/lf20_76m8m1.json',
                  );
                }).toList()
              : [
                  _buildSingleBanner(
                    const Color(0xFF0C831F),
                    "Fresh Delivery\nEVERYDAY",
                    "https://assets9.lottiefiles.com/packages/lf20_76m8m1.json",
                  ),
                  _buildSingleBanner(
                    const Color(0xFF5F25D9),
                    "MEGA SAVINGS\non Snacking",
                    "https://assets4.lottiefiles.com/packages/lf20_m6cuL6.json",
                  ),
                  _buildSingleBanner(
                    const Color(0xFFFC8019),
                    "Summer Fruits\nUp to 30% OFF",
                    "https://assets10.lottiefiles.com/packages/lf20_rc63p8u1.json",
                  ),
                ],
        ),
      );
    });
  }

  Widget _buildSingleBanner(Color color, String title, String lottieUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.95), color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -15,
            top: -15,
            child: Lottie.network(
              lottieUrl,
              width: 130,
              errorBuilder: (c, e, s) => const Icon(
                Icons.local_offer_rounded,
                size: 40,
                color: Colors.white54,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: 0.2,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "ORDER NOW",
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
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
        _buildSectionHeader(
          "Shop by Category",
          onSeeAll: () => Get.toNamed('/all-categories'),
          icon: Icons.grid_view_rounded,
        ),
        Obx(() {
          if (controller.isLoading.value && controller.categories.isEmpty) {
            return _buildCategoryGridShimmer();
          }

          return SizedBox(
            height: 200,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                final color = _getCategoryColor(cat.name);

                return GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      '/product-list',
                      parameters: {'title': cat.name},
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 54,
                          width: 54,
                          padding: const EdgeInsets.all(4),
                          child: cat.image.isNotEmpty
                              ? Image.network(
                                  cat.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) =>
                                      _getCategoryIcon(cat.name),
                                )
                              : _getCategoryIcon(cat.name),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            cat.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
    IconData icon = Icons.shopping_bag_rounded;
    final n = name.toLowerCase();
    if (n.contains("fruit") || n.contains("veg")) {
      icon = Icons.apple_rounded;
    } else if (n.contains("milk") || n.contains("dairy"))
      icon = Icons.egg_rounded;
    else if (n.contains("drink") || n.contains("juice"))
      icon = Icons.local_drink_rounded;
    else if (n.contains("snack") || n.contains("munch"))
      icon = Icons.fastfood_rounded;
    else if (n.contains("clean"))
      icon = Icons.cleaning_services_rounded;
    else if (n.contains("meat"))
      icon = Icons.kebab_dining_rounded;

    return Icon(icon, size: 28, color: _getCategoryColor(name));
  }

  Color _getCategoryColor(String name) {
    final n = name.toLowerCase();
    if (n.contains("fruit") || n.contains("veg")) {
      return const Color(0xFF4CAF50);
    }
    if (n.contains("milk") || n.contains("dairy")) {
      return const Color(0xFF2196F3);
    }
    if (n.contains("drink") || n.contains("juice")) {
      return const Color(0xFFFF9800);
    }
    if (n.contains("snack") || n.contains("munch")) {
      return const Color(0xFFE91E63);
    }
    if (n.contains("clean")) return const Color(0xFF00BCD4);
    if (n.contains("meat")) return const Color(0xFFF44336);
    return AppColors.primaryColor;
  }

  Widget _buildCategoryGridShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      child: SizedBox(
        height: 200,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: 8,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalProducts(HomeController controller) {
    return SizedBox(
      height: 215, // Compact height for horizontal list to match Swiggy style
      child: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const SizedBox();
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          itemCount: controller.products.length,
          itemBuilder: (context, index) => Container(
            width: 142,
            margin: const EdgeInsets.only(
              right: 12,
              bottom: 12,
            ),
            child: _buildProductCard(controller.products[index]),
          ),
        );
      }),
    );
  }

  Widget _buildProductGrid(HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return const SizedBox();
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.83, // Optimized aspect ratio to remove empty white space
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) =>
            _buildProductCard(controller.products[index]),
      );
    });
  }

  Widget _buildProductCard(Product product) {
    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;
    final discountPercent = hasDiscount
        ? ((product.originalPrice! - product.price) / product.originalPrice! * 100).round()
        : 20; // fallback to default vibrant discount
    final displayOriginalPrice = hasDiscount ? product.originalPrice!.round() : (product.price * 1.25).round();
    return GestureDetector(
      onTap: () => Get.toNamed('/product-details', arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 115,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.grey,
                        size: 36,
                      ),
                    ),
                  ),
                  // Swiggy discount badge top-left
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6E28E9), // Authentic Swiggy Instamart Violet
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(11),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        "$discountPercent% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  // Swiggy delivery speed badge bottom-left
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFFF5722), // Swiggy Orange
                            size: 11,
                          ),
                          const SizedBox(width: 1),
                          Text(
                            "9 MINS",
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.25,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.unit,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹${product.price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "₹$displayOriginalPrice",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        AddToCartButton(product: product),
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

  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onSeeAll,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        24,
        AppConstants.defaultPadding,
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primaryColor, size: 22),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "See all",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmer({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  void _showLocationDialog(LocationController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Delivery Location",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 20),
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBottomSheetItem(
              Icons.my_location_rounded,
              "Current Location",
              controller.currentAddress.value,
              () {
                controller.setActiveAddress(
                  "current",
                  controller.currentAddress.value,
                );
                Get.back();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.grey.shade200, thickness: 1.5),
            ),
            ...controller.savedAddresses.map(
              (addr) => _buildBottomSheetItem(
                Icons.home_work_rounded,
                addr['title']!,
                addr['address']!,
                () {
                  controller.setActiveAddress(addr['id']!, addr['address']!);
                  Get.back();
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.toNamed('/addresses');
                },
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text(
                  "Manage Addresses",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 3,
                  shadowColor: AppColors.primaryColor.withOpacity(0.35),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBottomSheetItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
