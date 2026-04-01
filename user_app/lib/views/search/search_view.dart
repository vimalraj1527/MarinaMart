import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_search_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../widgets/add_to_cart_button.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductSearchController controller = Get.put(ProductSearchController());
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search groceries...",
            border: InputBorder.none,
          ),
          onChanged: (value) => controller.searchProducts(value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.grey),
            onPressed: () {
              textController.clear();
              controller.clearSearch();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.searchResults.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.searchQuery.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 80, color: AppColors.greyLight),
                SizedBox(height: 16),
                Text("Search for eggs, milk, meat...", style: TextStyle(color: AppColors.grey)),
              ],
            ),
          );
        }

        if (controller.searchResults.isEmpty && !controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 80, color: AppColors.greyLight),
                const SizedBox(height: 16),
                Text("No results for '${controller.searchQuery.value}'", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey)),
              ],
            ),
          );
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
            return GestureDetector(
              onTap: () => Get.toNamed('/product-details', arguments: product),
              child: _buildResultCard(product),
            );
          },
        );
      }),
    );
  }

  Widget _buildResultCard(product) {
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
              child: Image.network(product.image, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50, color: AppColors.greyLight)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(product.unit, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₹${product.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryColor)),
                    AddToCartButton(product: product),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
