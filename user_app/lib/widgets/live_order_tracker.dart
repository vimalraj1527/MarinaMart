import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

// ─── Status step configuration ───────────────────────────────────────────────
class _StatusStep {
  final String label;
  final IconData icon;
  final String shortLabel;
  const _StatusStep(this.label, this.icon, this.shortLabel);
}

const _steps = [
  _StatusStep('Pending',          Icons.receipt_long_rounded,   'Order\nPlaced'),
  _StatusStep('Processing',       Icons.restaurant_rounded,     'Preparing\nYour Order'),
  _StatusStep('Out for Delivery', Icons.delivery_dining_rounded,'On The\nWay'),
  _StatusStep('Delivered',        Icons.check_circle_rounded,   'Delivered'),
];

int _stepIndex(String status) {
  switch (status) {
    case 'Pending':          return 0;
    case 'Processing':       return 1;
    case 'Out for Delivery': return 2;
    case 'Delivered':        return 3;
    default:                 return 0;
  }
}

// ─── Main Widget ─────────────────────────────────────────────────────────────
class LiveOrderTracker extends StatefulWidget {
  const LiveOrderTracker({super.key});

  @override
  State<LiveOrderTracker> createState() => _LiveOrderTrackerState();
}

class _LiveOrderTrackerState extends State<LiveOrderTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrdersController>();
    return Obx(() {
      final order = ctrl.activeOrder;
      if (order == null) return const SizedBox.shrink();
      return _buildCard(order);
    });
  }

  Widget _buildCard(OrderModel order) {
    final step = _stepIndex(order.status);
    final isCancelled = order.status == 'Cancelled';

    return GestureDetector(
      onTap: () => Get.toNamed('/track-order', arguments: order),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isCancelled
              ? const LinearGradient(colors: [Color(0xFF424242), Color(0xFF212121)])
              : const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: (isCancelled ? Colors.black : const Color(0xFF2C5364))
                  .withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative glow circle
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(order, isCancelled),
                    if (!isCancelled) ...[
                      const SizedBox(height: 18),
                      _buildStepper(step),
                      const SizedBox(height: 12),
                      _buildCurrentStatus(order, step),
                    ] else ...[
                      const SizedBox(height: 10),
                      const Text(
                        'This order has been cancelled.',
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _buildFooter(order),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header row ──────────────────────────────────────────────────────────────
  Widget _buildHeader(OrderModel order, bool isCancelled) {
    return Row(
      children: [
        // Live badge
        if (!isCancelled)
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Opacity(
              opacity: _pulse.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 7),
                    SizedBox(width: 4),
                    Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
            child: const Text('CANCELLED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            order.orderNumber,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),
        // Arrow
        const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
      ],
    );
  }

  // ── Stepper ─────────────────────────────────────────────────────────────────
  Widget _buildStepper(int currentStep) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final lineIndex = i ~/ 2;
          final completed = lineIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: completed
                    ? const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00BCD4)])
                    : null,
                color: completed ? null : Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }
        // Dot
        final dotIndex = i ~/ 2;
        final isCompleted = dotIndex < currentStep;
        final isActive = dotIndex == currentStep;
        return _buildDot(dotIndex, isCompleted, isActive);
      }),
    );
  }

  Widget _buildDot(int index, bool completed, bool active) {
    final step = _steps[index];
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        double size = completed || active ? 32 : 26;
        if (active) size = 32 + (_pulse.value * 4);

        return SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed
                    ? const Color(0xFF00E676)
                    : active
                        ? Colors.white
                        : Colors.white12,
                boxShadow: active
                    ? [BoxShadow(color: Colors.white.withOpacity(0.3 * _pulse.value), blurRadius: 10, spreadRadius: 2)]
                    : completed
                        ? [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.4), blurRadius: 8)]
                        : [],
              ),
              child: Icon(
                completed ? Icons.check_rounded : step.icon,
                size: completed ? 14 : (active ? 16 : 13),
                color: completed
                    ? Colors.white
                    : active
                        ? const Color(0xFF0F2027)
                        : Colors.white38,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Current status label ────────────────────────────────────────────────────
  Widget _buildCurrentStatus(OrderModel order, int step) {
    final s = _steps[step.clamp(0, _steps.length - 1)];
    final messages = [
      'We received your order and it\'s being confirmed.',
      '🍳 Our team is preparing your fresh items now!',
      '🚴 Your delivery partner is on the way!',
      '✅ Order delivered. Enjoy your groceries!',
    ];
    return Row(
      children: [
        Icon(s.icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.status,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.2),
              ),
              const SizedBox(height: 2),
              Text(
                messages[step.clamp(0, messages.length - 1)],
                style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────
  Widget _buildFooter(OrderModel order) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 14),
              const SizedBox(width: 5),
              Text(
                '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.currency_rupee, color: Colors.white38, size: 13),
              Text(
                order.totalAmount.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Text(
            'Track Order',
            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3),
          ),
        ),
      ],
    );
  }
}
