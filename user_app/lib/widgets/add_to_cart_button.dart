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
      
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: count == 0
            ? GestureDetector(
                key: const ValueKey('add_button'),
                onTap: () {
                  if (product != null) controller.addToCart(product!);
                },
                child: Container(
                  height: 32,
                  width: 75,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ADD",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.add, color: AppColors.primaryColor, size: 16),
                    ],
                  ),
                ),
              )
            : Container(
                key: const ValueKey('counter_button'),
                height: 32,
                width: 75,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => controller.removeFromCart(product!),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.remove, color: Colors.white, size: 16),
                      ),
                    ),
                    Text(
                      "$count",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.addToCart(product!),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}
