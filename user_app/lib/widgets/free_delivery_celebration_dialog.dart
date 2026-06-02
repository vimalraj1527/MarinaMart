import 'dart:math';
import 'package:flutter/material.dart';

class FreeDeliveryCelebrationDialog extends StatefulWidget {
  const FreeDeliveryCelebrationDialog({super.key});

  @override
  State<FreeDeliveryCelebrationDialog> createState() => _FreeDeliveryCelebrationDialogState();
}

class _FreeDeliveryCelebrationDialogState extends State<FreeDeliveryCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _scaleAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  late AnimationController _particleController;
  final List<CelebrationParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 1. Pop-out scale animation
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
    _cardController.forward();

    // 2. Bouncing bike icon animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // 3. Particle engine
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.update();
          }
        });
      });

    // Spawn 50 colorful confetti particles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;
      final double startX = screenSize.width / 2;
      final double startY = screenSize.height / 2 - 80;

      final colors = [
        const Color(0xFF10B981), // Emerald Green
        const Color(0xFFFFD700), // Gold
        const Color(0xFF3B82F6), // Blue
        const Color(0xFFEF4444), // Red
        const Color(0xFFF59E0B), // Orange
        const Color(0xFFEC4899), // Pink
      ];

      for (int i = 0; i < 60; i++) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 4.0 + _random.nextDouble() * 8.0;
        _particles.add(
          CelebrationParticle(
            x: startX,
            y: startY,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 3.0, // Upward burst offset
            size: 4.0 + _random.nextDouble() * 6.0,
            rotation: _random.nextDouble() * 2 * pi,
            rotationSpeed: -0.1 + _random.nextDouble() * 0.2,
            color: colors[_random.nextInt(colors.length)],
            isCircle: _random.nextBool(),
          ),
        );
      }
      _particleController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _bounceController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Native Confetti Canvas Layer
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: CelebrationConfettiPainter(particles: _particles),
              ),
            ),
          ),
          // Bouncing celebratory popup card
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top header: Sunburst and animated delivery icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 140,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFD1FAE5), Color(0xFFECFDF5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Bouncing bike delivery icon
                        AnimatedBuilder(
                          animation: _bounceAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _bounceAnimation.value),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delivery_dining_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      "FREE DELIVERY!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF065F46),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Awesome! You have unlocked FREE Scheduled Delivery on this order.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // CTA Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                          ),
                          child: const Text(
                            "Awesome!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CelebrationParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  bool isCircle;

  CelebrationParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.isCircle,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.18; // Gravity pulling particles down
    vx *= 0.98; // Air resistance horizontal deceleration
    rotation += rotationSpeed;
  }
}

class CelebrationConfettiPainter extends CustomPainter {
  final List<CelebrationParticle> particles;
  CelebrationConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (var particle in particles) {
      paint.color = particle.color;
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      if (particle.isCircle) {
        canvas.drawCircle(Offset.zero, particle.size, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size * 2,
            height: particle.size,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
