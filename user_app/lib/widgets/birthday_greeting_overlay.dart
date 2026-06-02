import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

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
    Color(0xFFD4AF37), // Metallic Gold
    Color(0xFFFFDF00), // Bright Gold
    Color(0xFFF3E5AB), // Mellow Champagne
    Color(0xFFC0C0C0), // Silver
    Color(0xFFFFFFFF), // White
    Color(0xFFE5D3B3), // Champagne Gold
  ];

  final List<Color> _balloonColors = const [
    Color(0xFFD4AF37), // Gold
    Color(0xFFE5D3B3), // Champagne
    Color(0xFFB8860B), // Dark Goldenrod
    Color(0xFFF3E5AB), // Soft Yellow Gold
    Color(0xFFCD7F32), // Bronze
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
      const Offset(25, 130),
      const Offset(50, 220),
      const Offset(-40, 290),
      const Offset(-20, 160),
    ];

    return positions.asMap().entries.map((e) {
      final offset = e.value;
      final delay = e.key * 0.25;
      return Positioned(
        left: offset.dx < 0 ? null : offset.dx,
        right: offset.dx < 0 ? -offset.dx : null,
        top: offset.dy,
        child: AnimatedBuilder(
          animation: _starSpin,
          builder: (_, __) => Transform.rotate(
            angle: _starSpin.value + delay * 2 * math.pi,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _confettiColors[e.key % _confettiColors.length].withOpacity(0.85),
              size: 24 + e.key * 6.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFFDF6),
                Color(0xFFFFF5E1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Top Right Decorative Glowing Orb
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4AF37).withOpacity(0.08),
                  ),
                ),
              ),
              // Bottom Left Decorative Glowing Orb
              Positioned(
                bottom: -60,
                left: -60,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4AF37).withOpacity(0.08),
                  ),
                ),
              ),
              // Close button at top right
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF805A00), size: 16),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Floating gold seal / cake holder
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD4AF37).withOpacity(0.08),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25), width: 1.5),
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD4AF37).withOpacity(0.15),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 2),
                          ),
                        ),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFF3E5AB), Color(0xFFD4AF37)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('🎂', style: TextStyle(fontSize: 36)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Happy Birthday Text & Headline
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          const Text(
                            "BLOOMARINA CELEBRATES YOU",
                            style: TextStyle(
                              color: Color(0xFF996515),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Happy Birthday',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2C220E),
                              letterSpacing: -0.5,
                              fontFamily: 'Outfit',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFAA771C), Color(0xFFF3E5AB)],
                            ).createShader(bounds),
                            child: Text(
                              _firstName,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                fontFamily: 'Outfit',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 1.5,
                            width: 140,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFD4AF37),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Wishing you a spectacular year ahead filled\nwith health, joy & wonderful discoveries! ✨',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF5D4A27),
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("🎁 ", style: TextStyle(fontSize: 16)),
                                Text(
                                  "Your Special Birthday Offer is Live!",
                                  style: TextStyle(
                                    color: Color(0xFF805A00),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFF996515)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF996515).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onClose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🛍️  ', style: TextStyle(fontSize: 18)),
                              Text(
                                'Shop Birthday Treats',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
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
