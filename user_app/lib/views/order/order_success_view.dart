import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final String rawMethod = (args?['paymentMethod'] ?? 'Online').toString();
    final String pMethod = rawMethod.toLowerCase();
    final bool isUpi = pMethod.contains('upi') || pMethod.contains('gpay') || pMethod.contains('google pay') || pMethod.contains('phonepe') || pMethod.contains('paytm');
    final bool isWallet = pMethod.contains('wallet');
    final bool isCod = pMethod.contains('cash') || pMethod.contains('cod');

    String titleText;
    String subtitleText;

    if (isUpi) {
      titleText = "Order Placed • Payment Approval Pending";
      subtitleText = "Your order has been placed via Google Pay / UPI! Your payment is under admin verification and will be confirmed shortly.";
    } else if (isWallet) {
      titleText = "Order Placed • Paid via Wallet";
      subtitleText = "Your order has been placed successfully and paid via your MaRinaMaRt Wallet balance. Store is preparing your items.";
    } else if (isCod) {
      titleText = "Order Placed • Cash on Delivery";
      subtitleText = "Your order has been placed successfully. Please pay with cash or UPI when your items are delivered to your doorstep.";
    } else {
      titleText = "Order Placed • $rawMethod";
      subtitleText = "Your order has been placed successfully via $rawMethod and will be prepared and delivered shortly.";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Native Success Tick Animation
              const SuccessTick(size: 200),
              
              const SizedBox(height: 35),
              Text(
                titleText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitleText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.grey, height: 1.4),
              ),
              
              const SizedBox(height: 40),
              
              // View My Orders Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Get.offNamed('/orders'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                    shadowColor: AppColors.primaryColor.withValues(alpha: 0.35),
                  ),
                  child: const Text("Track Order Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Get.offAllNamed('/home'),
                child: Text("Keep Shopping", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessTick extends StatefulWidget {
  final double size;
  const SuccessTick({super.key, this.size = 180});

  @override
  State<SuccessTick> createState() => _SuccessTickState();
}

class _SuccessTickState extends State<SuccessTick> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550), // Snappy and fast play speed
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: CustomPaint(
              painter: SuccessCheckPainter(progress: _checkAnimation.value),
            ),
          );
        },
      ),
    );
  }
}

class SuccessCheckPainter extends CustomPainter {
  final double progress;
  SuccessCheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (radius <= 8) return;

    // Draw the green background circle
    final circlePaint = Paint()
      ..color = const Color(0xFF10B981) // Premium Emerald Green
      ..style = PaintingStyle.fill;
    
    // Subtle shadow behind the green circle
    final shadowPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius - 8, shadowPaint);
    canvas.drawCircle(center, radius - 8, circlePaint);

    // Draw check mark path
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.085;

    final path = Path();
    // Starting point of the check mark: bottom-left-ish
    final startX = size.width * 0.34;
    final startY = size.height * 0.5;
    
    // Middle point: bottom-center-ish
    final midX = size.width * 0.46;
    final midY = size.height * 0.61;

    // End point: top-right-ish
    final endX = size.width * 0.66;
    final endY = size.height * 0.39;

    path.moveTo(startX, startY);
    path.lineTo(midX, midY);
    path.lineTo(endX, endY);

    // Animate the drawing of the check mark path
    final checkPath = Path();
    final totalPathMetric = path.computeMetrics().first;
    final extractPath = totalPathMetric.extractPath(0, totalPathMetric.length * progress);
    
    canvas.drawPath(extractPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant SuccessCheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
