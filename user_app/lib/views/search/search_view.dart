import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_search_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/main_shell_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/add_to_cart_button.dart';
import '../../models/product_model.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final ProductSearchController controller = Get.put(ProductSearchController());
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool _isNavigatingToDetails = false;

  final List<String> trendingSearches = [
    "Milk",
    "Curd & Yogurt",
    "Fresh Bread",
    "Alphonso Mango",
    "Tender Coconut",
    "Potato Chips",
    "Paneer",
    "Cold Drinks"
  ];

  @override
  void initState() {
    super.initState();
    
    // Listen to query changes for autocompletion suggestions
    textController.addListener(() {
      controller.updateSuggestions(textController.text);
    });

    // Check if voice search should be triggered immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear old search data to ensure it opens fresh
      controller.clearSearch();
      
      final args = Get.arguments;
      if (args != null && args is Map && args['triggerVoice'] == true) {
        _showVoiceSearchBottomSheet(context);
      } else {
        focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _showVoiceSearchBottomSheet(BuildContext context) {
    focusNode.unfocus();
    Get.bottomSheet(
      VoiceSearchSheet(
        onRecognized: (text) {
          Get.back();
          textController.text = text;
          textController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
          controller.searchProducts(text);
        },
      ),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.6),
    ).then((_) {
      if (textController.text.isEmpty && mounted) {
        focusNode.requestFocus();
      }
    });
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));
    final int index = text.toLowerCase().indexOf(query.toLowerCase());
    if (index == -1) return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600));
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 15, fontFamily: 'Outfit'),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryColor),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                try {
                  final MainShellController shellController = Get.find<MainShellController>();
                  shellController.changeTab(0);
                } catch (_) {
                  Get.back();
                }
              }
            },
          ),
        ),
        titleSpacing: 8,
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.search_rounded, color: Colors.black45, size: 22),
              ),
              Expanded(
                child: TextField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: "Search items, categories...",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w700),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      controller.searchProducts(value);
                    }
                  },
                ),
              ),
              Obx(() => textController.text.isNotEmpty || controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black45, size: 20),
                    onPressed: () {
                      textController.clear();
                      controller.clearSearch();
                      focusNode.requestFocus();
                    },
                  )
                : const SizedBox.shrink()
              ),
              IconButton(
                icon: Icon(Icons.mic_rounded, color: AppColors.primaryColor, size: 22),
                onPressed: () => _showVoiceSearchBottomSheet(context),
              ),
            ],
          ),
        ),
        actions: const [SizedBox(width: 12)],
      ),
      body: Obx(() {
        // Typing Phase: Show autocompletion suggestions
        if (textController.text.isNotEmpty && controller.searchResults.isEmpty && controller.suggestions.isNotEmpty) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: controller.suggestions.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
            itemBuilder: (context, index) {
              final suggestion = controller.suggestions[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                ),
                title: _buildHighlightedText(suggestion, textController.text),
                trailing: const Icon(Icons.arrow_outward_rounded, color: Colors.black38, size: 18),
                onTap: () {
                  textController.text = suggestion;
                  textController.selection = TextSelection.fromPosition(TextPosition(offset: suggestion.length));
                  controller.searchProducts(suggestion);
                  focusNode.unfocus();
                },
              );
            },
          );
        }

        // Loading state
        if (controller.isLoading.value && controller.searchResults.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
        }

        // Empty state: show Recents, Trendings & Categories
        if (textController.text.isEmpty && controller.searchQuery.isEmpty) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Searches
                if (controller.recentSearches.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Searches",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () => controller.clearRecentSearches(),
                        child: Text(
                          "Clear All",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.recentSearches.map((query) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200, width: 1.2),
                      ),
                      child: InkWell(
                        onTap: () {
                          textController.text = query;
                          textController.selection = TextSelection.fromPosition(TextPosition(offset: query.length));
                          controller.searchProducts(query);
                          focusNode.unfocus();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history_rounded, size: 15, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text(
                                query,
                                style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => controller.removeRecentSearch(query),
                                child: Icon(Icons.close_rounded, size: 14, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 28),
                ],

                // Trending Searches
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      "Trending Searches",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: trendingSearches.map((trend) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor.withOpacity(0.08), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.2), width: 1.2),
                    ),
                    child: InkWell(
                      onTap: () {
                        textController.text = trend;
                        textController.selection = TextSelection.fromPosition(TextPosition(offset: trend.length));
                        controller.searchProducts(trend);
                        focusNode.unfocus();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up_rounded, size: 15, color: AppColors.primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              trend,
                              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 28),

                // Browse Categories
                const Text(
                  "Browse Categories",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                _buildBrowseCategoriesGrid(),
              ],
            ),
          );
        }

        // Search returns no results
        if (controller.searchResults.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: const Icon(Icons.search_off_rounded, size: 70, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No results found for '${controller.searchQuery.value}'",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please check spelling or try searching for another ingredient.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Results Grid
        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final product = controller.searchResults[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _isNavigatingToDetails = true;
                });
                Get.toNamed('/product-details', arguments: {
                  'product': product,
                  'heroTag': "search_prod_${product.id}",
                })?.then((_) {
                  if (mounted) {
                    setState(() {
                      _isNavigatingToDetails = false;
                    });
                  }
                });
              },
              child: _buildResultCard(product, _isNavigatingToDetails),
            );
          },
        );
      }),
    );
  }

  Widget _buildBrowseCategoriesGrid() {
    try {
      final homeController = Get.find<HomeController>();
      if (homeController.categories.isEmpty) return const SizedBox.shrink();
      
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: homeController.categories.length,
        itemBuilder: (context, index) {
          final cat = homeController.categories[index];
          final color = _getCategoryColor(cat.name);
          return InkWell(
            onTap: () {
              final catName = cat.name.toLowerCase();
              final catProducts = homeController.products.where((p) {
                final pCat = p.category.toLowerCase();
                return pCat.contains(catName) || catName.contains(pCat);
              }).toList();
              Get.toNamed('/product-list', arguments: catProducts, parameters: {'title': cat.name});
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.15), width: 1),
                  ),
                  child: cat.image.isNotEmpty 
                      ? Image.network(cat.image, fit: BoxFit.contain, errorBuilder: (c,e,s) => _getCategoryIcon(cat.name, color))
                      : _getCategoryIcon(cat.name, color),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _getCategoryIcon(String name, Color color) {
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
    return Icon(icon, size: 24, color: color);
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

  Widget _buildResultCard(Product product, bool heroEnabled) {
    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;
    final discountPercent = hasDiscount
        ? (((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            height: 100,
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Stack(
              children: [
                Center(
                  child: HeroMode(
                    enabled: heroEnabled,
                    child: Hero(
                      tag: "search_prod_${product.id}",
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag_rounded, color: Colors.grey, size: 32),
                      ),
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
                if (hasDiscount)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE02020),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: Text(
                        "$discountPercent% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, height: 1.2, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        product.unit,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 9.5, fontWeight: FontWeight.bold),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "₹${product.price}",
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: Colors.black87),
                            ),
                            if (hasDiscount)
                              Text(
                                "₹${product.originalPrice}",
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: Colors.grey.shade400,
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.bold,
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
    );
  }
}

class VoiceSearchSheet extends StatefulWidget {
  final Function(String) onRecognized;
  const VoiceSearchSheet({super.key, required this.onRecognized});

  @override
  State<VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<VoiceSearchSheet> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _statusText = "Listening...";
  String _subText = "Try saying 'fresh milk' or 'paneer'";
  Timer? _timer;
  
  final List<String> _sampleItems = [
    "Fresh Milk",
    "Alphonso Mango",
    "Tender Coconut",
    "Potato Chips",
    "Butter Paneer",
    "Cold Coffee",
    "Brown Bread",
    "Farm Fresh Eggs"
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );

    // Simulate voice recognition after 2.2 seconds
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _statusText = "Sounds like...";
          // Pick a random sample item
          _subText = (_sampleItems..shuffle()).first;
        });
        
        // Wait 1 second before executing search
        Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            widget.onRecognized(_subText);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 25),
          Text(
            _statusText,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 12),
          Text(
            _subText,
            style: TextStyle(
              color: _statusText.contains("Sounds") ? AppColors.primaryColor : Colors.grey.shade500,
              fontSize: 16,
              fontWeight: _statusText.contains("Sounds") ? FontWeight.w900 : FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 45),
          // Pulsing Soundwave Circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110 * _pulseAnimation.value,
                    height: 110 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.12 - (_pulseController.value * 0.06)),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 90 * _pulseAnimation.value,
                    height: 90 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.22 - (_pulseController.value * 0.1)),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primaryColor, AppColors.primaryColor.withGreen(100)]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.35),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 36),
                  ),
                ],
              );
            }
          ),
          const SizedBox(height: 45),
          // Tap to cancel
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
