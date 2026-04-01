import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_search_controller.dart';
import '../../models/category_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/add_to_cart_button.dart';

class CategoryProductsView extends StatefulWidget {
  const CategoryProductsView({super.key});

  @override
  State<CategoryProductsView> createState() => _CategoryProductsViewState();
}

class _CategoryProductsViewState extends State<CategoryProductsView> {
  final ProductSearchController controller = Get.put(ProductSearchController());
  late Category category;

  @override
  void initState() {
    super.initState();
    category = Get.arguments;
    controller.searchByCategory(category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.searchResults.isEmpty) {
          return const Center(child: Text("No products in this category."));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final product = controller.searchResults[index];
            return Container(
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
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
                      child: Hero(tag: "cat_prod_${product.id}", child: Image.network(product.image, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.image))),
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
            );
          },
        );
      }),
    );
  }
}
