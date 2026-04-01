import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../utils/app_colors.dart';

class AddToCartButton extends StatelessWidget {
  final Product? product;
  const AddToCartButton({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();
    
    return Obx(() {
      int count = controller.getItemCount(product?.id ?? "");
      
      if (count == 0) {
        return GestureDetector(
          onTap: () {
            if (product != null) controller.addToCart(product!);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.primaryColor, width: 1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("ADD", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w900, fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.add, color: AppColors.primaryColor, size: 14),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => controller.removeFromCart(product!),
              child: const Icon(Icons.remove, color: Colors.white, size: 18),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "$count", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
            GestureDetector(
              onTap: () => controller.addToCart(product!),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ],
        ),
      );
    });
  }
}
