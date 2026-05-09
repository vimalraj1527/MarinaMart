import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../utils/app_colors.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void triggerMeteorDropCartAnimation(
  BuildContext context,
  Product product,
  CartController controller,
  RenderBox renderBox,
) {
  HapticFeedback.lightImpact();
  controller.addToCart(product);

  final startPosition = renderBox.localToGlobal(Offset.zero);
  final endPosition = Offset(
    MediaQuery.of(context).size.width / 2 - 25,
    MediaQuery.of(context).size.height - 70,
  );

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return FlyingCartItem(
        start: startPosition,
        end: endPosition,
        imageUrl: product.image,
        onComplete: () {
          if (entry.mounted) entry.remove();
        },
      );
    },
  );
  Overlay.of(context).insert(entry);
}

class AddToCartButton extends StatelessWidget {
  final Product? product;
  const AddToCartButton({super.key, this.product});

  void _triggerAddToCartAnimation(
    BuildContext context,
    CartController controller,
  ) {
    if (product == null) return;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      triggerMeteorDropCartAnimation(context, product!, controller, renderBox);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    return Obx(() {
      int count = controller.getItemCount(product?.id ?? "");

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.elasticOut,
        switchOutCurve: Curves.easeInBack,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: count == 0
            ? Builder(
                key: const ValueKey('add_button'),
                builder: (ctx) => GestureDetector(
                  onTap: () => _triggerAddToCartAnimation(ctx, controller),
                  child: Container(
                    height: 36,
                    width: 78,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
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
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.add_rounded,
                          color: AppColors.primaryColor,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                key: const ValueKey('counter_button'),
                height: 36,
                width: 86,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), AppColors.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        controller.removeFromCart(product!);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: const Icon(
                          Icons.remove_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
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
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () =>
                            _triggerAddToCartAnimation(ctx, controller),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}

class FlyingCartItem extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String imageUrl;
  final VoidCallback onComplete;

  const FlyingCartItem({
    super.key,
    required this.start,
    required this.end,
    required this.imageUrl,
    required this.onComplete,
  });

  @override
  State<FlyingCartItem> createState() => _FlyingCartItemState();
}

class _FlyingCartItemState extends State<FlyingCartItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // X arcs out widely like a boomerang before coming back to the center
    _xAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.start.dx,
          end: widget.start.dx > 200 ? 20 : 350,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.start.dx > 200 ? 20 : 350,
          end: widget.end.dx,
        ).chain(CurveTween(curve: Curves.easeInOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);

    // Y shoots UP high into the sky, hangs there, then SLAMS down elastically
    _yAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.start.dy,
          end: widget.start.dy - 300,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.start.dy - 300,
          end: widget.end.dy,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Inflates MASSIVELY, then shrinks into a tiny spec
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 2.5,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 2.5,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInQuint)),
        weight: 60,
      ),
    ]).animate(_controller);

    // SPINS rapidly (4 complete rotations)
    _rotateAnimation = Tween<double>(begin: 0, end: math.pi * 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _xAnimation.value,
          top: _yAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.9),
                      blurRadius: 40,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF007F).withOpacity(0.9),
                      blurRadius: 50,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: widget.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.star_rounded,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.star_rounded, color: Colors.black),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
