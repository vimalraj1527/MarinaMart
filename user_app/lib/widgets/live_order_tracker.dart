import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/order_model.dart';

// ─── Per-status config ────────────────────────────────────────────────────────
String _statusEmoji(OrderModel order) {
  if (order.paymentStatus == 'Payment In Progress') return '⏳';
  switch (order.status) {
    case 'Pending':          return '🧾';
    case 'Processing':       return '🍳';
    case 'Out for Delivery': return '🛵';
    case 'Delivered':        return '✅';
    default:                 return '📦';
  }
}

String _statusHint(OrderModel order) {
  if (order.paymentStatus == 'Payment In Progress') return 'Awaiting Admin UPI verification…';
  switch (order.status) {
    case 'Pending':          return 'Confirming your order…';
    case 'Processing':       return 'Being freshly prepared for you';
    case 'Out for Delivery': return 'Partner is heading your way!';
    case 'Delivered':        return 'Enjoy your groceries 🎉';
    default:                 return 'Tracking your order';
  }
}

Color _statusColor(OrderModel order) {
  if (order.paymentStatus == 'Payment In Progress') return const Color(0xFFFFA000);
  switch (order.status) {
    case 'Pending':          return const Color(0xFFFF9800);
    case 'Processing':       return const Color(0xFF2196F3);
    case 'Out for Delivery': return const Color(0xFFFF9800);
    case 'Delivered':        return const Color(0xFF4CAF50);
    default:                 return const Color(0xFF9E9E9E);
  }
}

int _statusStep(OrderModel order) {
  if (order.paymentStatus == 'Payment In Progress') return 1;
  switch (order.status) {
    case 'Pending':          return 1;
    case 'Processing':       return 2;
    case 'Out for Delivery': return 3;
    case 'Delivered':        return 4;
    default:                 return 1;
  }
}

// ─── Sticky bottom bar ────────────────────────────────────────────────────────
class LiveOrderTrackerBar extends StatefulWidget {
  const LiveOrderTrackerBar({super.key});

  @override
  State<LiveOrderTrackerBar> createState() => _LiveOrderTrackerBarState();
}

class _LiveOrderTrackerBarState extends State<LiveOrderTrackerBar>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrdersController>();
    return Obx(() {
      final order = ctrl.activeOrder;
      if (order == null) return const SizedBox.shrink();
      return _buildBar(order);
    });
  }

  Widget _buildBar(OrderModel order) {
    final primary = ThemeController.to.primaryColor;
    final statusClr = _statusColor(order);
    final emoji = _statusEmoji(order);
    final hint = _statusHint(order);
    final step = _statusStep(order);
    final progress = step / 4;

    return GestureDetector(
      onTap: () => Get.toNamed('/track-order',
          arguments: Get.find<OrdersController>().activeOrder),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(top: BorderSide(color: statusClr.withOpacity(0.2), width: 1.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -6)),
            BoxShadow(color: statusClr.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Progress rail ─────────────────────────────────────
            Container(
              height: 3.5,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E8ED),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(colors: [statusClr.withOpacity(0.6), statusClr]),
                          boxShadow: [BoxShadow(color: statusClr.withOpacity(0.3), blurRadius: 4)],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _shimmerCtrl,
                        builder: (_, __) {
                          final dx = _shimmerCtrl.value * constraints.maxWidth * 1.5 - constraints.maxWidth * 0.2;
                          return Positioned(
                            left: dx, top: 0, bottom: 0,
                            child: Container(
                              width: 30,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(0.5), Colors.transparent]),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Content Row ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 14, 14),
              child: Row(
                children: [
                  // Pulsing status icon
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusClr.withOpacity(0.06 + _pulseCtrl.value * 0.06),
                        border: Border.all(
                          color: statusClr.withOpacity(0.15 + _pulseCtrl.value * 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Status text
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) => Container(
                                width: 6, height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusClr.withOpacity(0.4 + _pulseCtrl.value * 0.6),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                order.paymentStatus == 'Payment In Progress' ? 'Payment Approval Pending' : order.status,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.1,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hint,
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Track pill button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [primary, primary.withOpacity(0.85)]),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Track', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
                        const SizedBox(width: 5),
                        Transform.rotate(
                          angle: -math.pi / 4,
                          child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
