import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ─── Confetti Particle Model ───────────────────────────────────────────────────
class _Particle {
  double x, y, vx, vy, radius, opacity;
  Color color;
  double rotation, vRotation;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
    required this.color,
    required this.rotation,
    required this.vRotation,
  });
}

// ─── Confetti Painter ─────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);

      final rect = Rect.fromCenter(center: Offset.zero, width: p.radius * 2.5, height: p.radius * 1.2);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

// ─── Balloon Painter ─────────────────────────────────────────────────────────
class _BalloonWidget extends StatelessWidget {
  final Color color;
  final double size;
  const _BalloonWidget({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.3),
      painter: _BalloonPainter(color),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  final Color color;
  _BalloonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.fill;
    final stringPaint = Paint()..color = Colors.grey.shade500..strokeWidth = 1.2..style = PaintingStyle.stroke;

    // Balloon body
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height * 0.75), paint);

    // Highlight
    canvas.drawOval(Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.3, size.height * 0.2), highlightPaint);

    // Knot
    final knotPaint = Paint()..color = color.withOpacity(0.85)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.76), 4, knotPaint);

    // String
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.92, size.width / 2, size.height);
    canvas.drawPath(path, stringPaint);
  }

  @override
  bool shouldRepaint(_BalloonPainter old) => false;
}

// ─── Main Birthday Greeting Overlay ──────────────────────────────────────────
class BirthdayGreetingOverlay extends StatefulWidget {
  final String userName;
  final VoidCallback onClose;

  const BirthdayGreetingOverlay({
    super.key,
    required this.userName,
    required this.onClose,
  });

  @override
  State<BirthdayGreetingOverlay> createState() => _BirthdayGreetingOverlayState();
}

class _BirthdayGreetingOverlayState extends State<BirthdayGreetingOverlay>
    with TickerProviderStateMixin {
  // Confetti
  final _random = math.Random();
  final List<_Particle> _particles = [];
  Timer? _confettiTimer;

  // Animation controllers
  late AnimationController _cardController;
  late AnimationController _textController;
  late AnimationController _balloonController;
  late AnimationController _starController;

  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;
  late Animation<double> _textFade;
  late Animation<double> _balloonFloat;
  late Animation<double> _starSpin;

  final List<Color> _confettiColors = const [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFF8B94),
    Color(0xFFA8E6CF),
    Color(0xFFDDA0DD),
  ];

  final List<Color> _balloonColors = const [
    Color(0xFFFF6B6B),
    Color(0xFFFFAB40),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
  ];

  @override
  void initState() {
    super.initState();

    // Card entrance animation
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _cardScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _cardController, curve: Curves.elasticOut));
    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _cardController, curve: const Interval(0.0, 0.4)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));

    // Text cascade animation
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Balloon floating
    _balloonController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _balloonFloat = Tween<double>(begin: -8.0, end: 8.0).animate(CurvedAnimation(parent: _balloonController, curve: Curves.easeInOut));

    // Star rotation
    _starController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _starSpin = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_starController);

    // Spawn confetti
    _spawnConfetti();
    _confettiTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateConfetti();
    });

    // Start entrance animations
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });
  }

  void _spawnConfetti() {
    for (int i = 0; i < 80; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.004,
        vy: 0.002 + _random.nextDouble() * 0.006,
        radius: 4.0 + _random.nextDouble() * 5.0,
        opacity: 0.8 + _random.nextDouble() * 0.2,
        color: _confettiColors[_random.nextInt(_confettiColors.length)],
        rotation: _random.nextDouble() * 2 * math.pi,
        vRotation: (_random.nextDouble() - 0.5) * 0.1,
      ));
    }
  }

  void _updateConfetti() {
    if (!mounted) return;
    setState(() {
      for (final p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.rotation += p.vRotation;
        p.vy += 0.00008; // Gravity
        if (p.y > 1.1) {
          // Reset to top
          p.y = -0.05;
          p.x = _random.nextDouble();
          p.vx = (_random.nextDouble() - 0.5) * 0.004;
          p.vy = 0.002 + _random.nextDouble() * 0.004;
          p.opacity = 0.8 + _random.nextDouble() * 0.2;
        }
      }
    });
  }

  @override
  void dispose() {
    _confettiTimer?.cancel();
    _cardController.dispose();
    _textController.dispose();
    _balloonController.dispose();
    _starController.dispose();
    super.dispose();
  }

  String get _firstName {
    final parts = widget.userName.trim().split(' ');
    return parts.isNotEmpty ? parts[0] : widget.userName;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark blurred backdrop
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.65),
            ),
          ),

          // Confetti Layer
          CustomPaint(
            size: size,
            painter: _ConfettiPainter(_particles),
          ),

          // Balloons at bottom corners
          Positioned(
            bottom: 30,
            left: 10,
            child: AnimatedBuilder(
              animation: _balloonFloat,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _balloonFloat.value),
                child: _BalloonWidget(color: _balloonColors[0], size: 55),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 60,
            child: AnimatedBuilder(
              animation: _balloonFloat,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, -_balloonFloat.value),
                child: _BalloonWidget(color: _balloonColors[2], size: 45),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 10,
            child: AnimatedBuilder(
              animation: _balloonFloat,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _balloonFloat.value * 0.8),
                child: _BalloonWidget(color: _balloonColors[3], size: 55),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 60,
            child: AnimatedBuilder(
              animation: _balloonFloat,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, -_balloonFloat.value * 0.7),
                child: _BalloonWidget(color: _balloonColors[4], size: 45),
              ),
            ),
          ),

          // Rotating stars in corners
          ..._buildRotatingStars(),

          // Main card
          Center(
            child: SlideTransition(
              position: _cardSlide,
              child: ScaleTransition(
                scale: _cardScale,
                child: FadeTransition(
                  opacity: _cardOpacity,
                  child: _buildCard(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRotatingStars() {
    final positions = [
      const Offset(20, 120),
      const Offset(40, 200),
      const Offset(-30, 280),
    ];

    return positions.asMap().entries.map((e) {
      final offset = e.value;
      final delay = e.key * 0.33;
      return Positioned(
        left: offset.dx < 0 ? null : offset.dx,
        right: offset.dx < 0 ? -offset.dx : null,
        top: offset.dy,
        child: AnimatedBuilder(
          animation: _starSpin,
          builder: (_, __) => Transform.rotate(
            angle: _starSpin.value + delay * 2 * math.pi,
            child: Icon(
              Icons.star_rounded,
              color: _confettiColors[e.key % _confettiColors.length].withOpacity(0.7),
              size: 22 + e.key * 5.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFDF2), Color(0xFFFFF9E6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Decorative top arc
              Positioned(
                top: -40,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD700).withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                top: -20,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFA500).withOpacity(0.08),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cake emoji with glow
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFA500).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🎂', style: TextStyle(fontSize: 44)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Happy Birthday headline
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF8B6508), Color(0xFFB8860B), Color(0xFFCD9B1D)],
                            ).createShader(bounds),
                            child: const Text(
                              '🎉 Happy Birthday!',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                fontFamily: 'Outfit',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _firstName,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                              fontFamily: 'Outfit',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1.5,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Color(0xFFFFD700), Colors.transparent],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Wishing you a day filled with\nfreshness, happiness & amazing deals! 🛒✨',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Sparkle row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: ['🎁', '🎈', '🎊', '🎈', '🎁']
                                .map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(e, style: const TextStyle(fontSize: 20)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: widget.onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 6,
                          shadowColor: AppColors.primaryColor.withOpacity(0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🛍️ ', style: TextStyle(fontSize: 18)),
                            Text(
                              'Shop Birthday Treats!',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
