import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/order_model.dart';
import '../../controllers/location_controller.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

// ─── Status Helpers ──────────────────────────────────────────────────────────
int _statusIndex(String s) {
  switch (s) {
    case 'Pending':          return 0;
    case 'Processing':       return 1;
    case 'Out for Delivery': return 2;
    case 'Delivered':        return 3;
    default:                 return 0;
  }
}

class _StepData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _StepData(this.title, this.subtitle, this.icon, this.color);
}



// ─── Main View ───────────────────────────────────────────────────────────────
class TrackOrderView extends StatefulWidget {
  const TrackOrderView({super.key});

  @override
  State<TrackOrderView> createState() => _TrackOrderViewState();
}

class _TrackOrderViewState extends State<TrackOrderView>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _riderCtrl;
  late OrderModel order;
  Timer? _refreshTimer;

  List<_StepData> get steps {
    final isPaymentInProgress = order.paymentStatus == 'Payment In Progress';
    final isPending = order.status == 'Pending';
    return [
      _StepData(
        isPaymentInProgress
            ? 'Payment Approval Pending'
            : (isPending ? 'Order Pending' : 'Payment Successful & Confirmed'),
        isPaymentInProgress
            ? 'Your UPI payment is under admin verification. Will be approved shortly!'
            : (isPending ? 'Waiting for store confirmation' : 'Your order has been verified & confirmed'),
        isPaymentInProgress ? Icons.hourglass_empty_rounded : Icons.check_circle_rounded,
        isPaymentInProgress ? Colors.amber.shade800 : const Color(0xFF4CAF50),
      ),
      const _StepData('Preparing', 'Store is packing your items with care', Icons.inventory_2_rounded, Color(0xFF2196F3)),
      const _StepData('On the Way', 'Rider is heading to your location', Icons.delivery_dining_rounded, Color(0xFFFF9800)),
      const _StepData('Delivered', 'Enjoy your fresh groceries!', Icons.home_rounded, Color(0xFF4CAF50)),
    ];
  }

  @override
  void initState() {
    super.initState();
    order = Get.arguments;
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _riderCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    // Setup periodic polling every 3 seconds for real-time status tracking
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshOrder();
    });
  }

  Future<void> _refreshOrder() async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.getData('/orders/${order.id}');
      if (response.statusCode == 200) {
        final updatedOrder = OrderModel.fromJson(jsonDecode(response.body));
        if (mounted && (updatedOrder.status != order.status || updatedOrder.paymentStatus != order.paymentStatus)) {
          setState(() {
            order = updatedOrder;
          });
        }
      }
    } catch (e) {
      print("Error polling track order status: $e");
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _riderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocationController locCtrl = Get.find<LocationController>();
    final int activeStep = _statusIndex(order.status);

    final LatLng dest = locCtrl.currentPosition.value != null
        ? LatLng(locCtrl.currentPosition.value!.latitude, locCtrl.currentPosition.value!.longitude)
        : const LatLng(12.9716, 77.5946);

    final primary = AppColors.primaryColor;
    final stepColor = steps[activeStep].color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // ── Soft gradient BG ─────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0, height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    stepColor.withOpacity(0.08),
                    const Color(0xFFF5F6FA),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── App Bar ──────────────────────────────────────────
                _buildAppBar(order, stepColor),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildStatusHero(order, activeStep, stepColor),
                        const SizedBox(height: 20),
                        _buildProgressBar(activeStep, stepColor),
                        const SizedBox(height: 24),
                        _buildTimeline(activeStep),
                        const SizedBox(height: 24),
                        _buildMapCard(dest),
                        const SizedBox(height: 20),
                        _buildOrderSummary(order),
                        const SizedBox(height: 20),
                        _buildActions(order, primary),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(OrderModel order, Color stepColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.orderNumber, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(order.paymentStatus == 'Payment In Progress' ? 'Payment Approval Pending' : 'Live Tracking', style: TextStyle(color: stepColor, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: stepColor.withOpacity(0.08 + _pulseCtrl.value * 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: stepColor.withOpacity(0.2 + _pulseCtrl.value * 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: stepColor)),
                  const SizedBox(width: 6),
                  Text('LIVE', style: TextStyle(color: stepColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Hero Card ───────────────────────────────────────────────────
  Widget _buildStatusHero(OrderModel order, int activeStep, Color stepColor) {
    final step = steps[activeStep];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stepColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(color: stepColor.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 62, height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stepColor.withOpacity(0.08 + _pulseCtrl.value * 0.05),
                border: Border.all(color: stepColor.withOpacity(0.2 + _pulseCtrl.value * 0.15), width: 2),
              ),
              child: Icon(step.icon, color: stepColor, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: TextStyle(color: stepColor, fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(step.subtitle, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w500)),
                if (order.status != 'Delivered') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Color(0xFFB0B0B0), size: 14),
                      const SizedBox(width: 4),
                      const Text('Estimated: 15-25 mins', style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress Bar ───────────────────────────────────────────────────────
  Widget _buildProgressBar(int activeStep, Color stepColor) {
    final progress = (activeStep + 1) / steps.length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Order Progress', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: stepColor, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 7,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8ED),
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(colors: [stepColor.withOpacity(0.7), stepColor]),
                      boxShadow: [BoxShadow(color: stepColor.withOpacity(0.25), blurRadius: 6)],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _shimmerCtrl,
                    builder: (_, __) {
                      final dx = _shimmerCtrl.value * constraints.maxWidth * 1.5 - constraints.maxWidth * 0.3;
                      return Positioned(
                        left: dx, top: 0, bottom: 0,
                        child: Container(
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(0.35), Colors.transparent]),
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
      ],
    );
  }

  // ── Timeline ───────────────────────────────────────────────────────────
  Widget _buildTimeline(int activeStep) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isCompleted = i <= activeStep;
          final isCurrent = i == activeStep;
          final isLast = i == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: isCurrent ? 36 : 28,
                      height: isCurrent ? 36 : 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? step.color.withOpacity(0.1) : const Color(0xFFF0F0F5),
                        border: Border.all(
                          color: isCompleted ? step.color : const Color(0xFFDCDCE0),
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                        boxShadow: isCurrent
                            ? [BoxShadow(color: step.color.withOpacity(0.2), blurRadius: 10)]
                            : [],
                      ),
                      child: Icon(
                        isCompleted ? step.icon : Icons.circle_outlined,
                        color: isCompleted ? step.color : const Color(0xFFCCCCD0),
                        size: isCurrent ? 18 : 14,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2.5,
                        height: 36,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted && i < activeStep ? step.color.withOpacity(0.3) : const Color(0xFFE8E8ED),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: isCurrent ? 4 : 2, bottom: isLast ? 0 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          color: isCompleted ? const Color(0xFF1A1A1A) : const Color(0xFFB0B0B5),
                          fontSize: isCurrent ? 16 : 14,
                          fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step.subtitle,
                        style: TextStyle(
                          color: isCompleted ? const Color(0xFF8E8E93) : const Color(0xFFCCCCD0),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Map Card ───────────────────────────────────────────────────────────
  Widget _buildMapCard(LatLng dest) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E8ED)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: dest, initialZoom: 15, interactionOptions: const InteractionOptions(flags: InteractiveFlag.none)),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.marinamart.user_app'),
                MarkerLayer(markers: [
                  Marker(
                    point: dest, width: 50, height: 50,
                    child: AnimatedBuilder(
                      animation: _riderCtrl,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, -4 * math.sin(_riderCtrl.value * math.pi)),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.35), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.home_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded, color: AppColors.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    const Text('Delivery Location', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel order) {
    double itemsTotal = 0;
    for (var item in order.items) {
      itemsTotal += (item.price * item.quantity);
    }

    double gst = itemsTotal * 0.05;

    // Mathematically reconstruct the delivery fee: TotalPaid + WalletApplied - ItemsTotal - GST
    double deliveryFee = order.totalAmount + order.walletAmountUsed - itemsTotal - gst;
    if (deliveryFee < 0.01) {
      deliveryFee = 0.0;
    }

    double displayTotal = order.totalAmount;
    if (displayTotal <= 0) {
      displayTotal = itemsTotal + gst + deliveryFee - order.walletAmountUsed;
      if (displayTotal < 0) displayTotal = 0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppColors.primaryColor, size: 18),
              const SizedBox(width: 8),
              const Text('Order Summary', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.productName, style: const TextStyle(color: Color(0xFF3A3A3A), fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text('${item.quantity} × ₹${item.price.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
          const Divider(color: Color(0xFFE8E8ED), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w600)),
              Text('₹${itemsTotal.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF3A3A3A), fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Taxes & GST (5%)', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w600)),
              Text('₹${gst.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF3A3A3A), fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Fee', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w600)),
              Text(
                deliveryFee == 0 ? 'FREE' : '₹${deliveryFee.toStringAsFixed(2)}',
                style: TextStyle(
                  color: deliveryFee == 0 ? AppColors.primaryColor : const Color(0xFF3A3A3A),
                  fontSize: 13,
                  fontWeight: deliveryFee == 0 ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
          if (order.walletAmountUsed > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Wallet Applied', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w600)),
                Text('-₹${order.walletAmountUsed.toStringAsFixed(2)}', style: TextStyle(color: Colors.orange.shade700, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
          const Divider(color: Color(0xFFE8E8ED), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Paid', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14, fontWeight: FontWeight.w800)),
              Text('₹${displayTotal.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Method', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                child: Text(order.paymentMethod, style: TextStyle(color: AppColors.primaryColor, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFFB0B0B5), size: 14),
              const SizedBox(width: 6),
              Expanded(child: Text(order.deliveryAddress, style: const TextStyle(color: Color(0xFFB0B0B5), fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────
  Widget _buildActions(OrderModel order, Color primary) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed('/direct-chat', arguments: order.orderNumber),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headset_mic_rounded, color: Color(0xFF8E8E93), size: 18),
                  SizedBox(width: 8),
                  Text('Help', style: TextStyle(color: Color(0xFF5A5A5F), fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, primary.withOpacity(0.85)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Center(
                child: Text('Back to Home', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
