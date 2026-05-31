import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';

class LoginSuccessView extends StatefulWidget {
  const LoginSuccessView({super.key});

  @override
  State<LoginSuccessView> createState() => _LoginSuccessViewState();
}

class _LoginSuccessViewState extends State<LoginSuccessView> with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _successController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    
    // Scanner Animation
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _scanLineAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOutSine),
    );

    // Success Animation
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeOutCubic),
    );

    _playIdentityVerificationSequence();
  }

  Future<void> _playIdentityVerificationSequence() async {
    // 1. Play scanning sequence
    _scanController.repeat(reverse: true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    HapticFeedback.lightImpact();
    
    // 2. Stop scanning, transition to success
    _scanController.stop();
    setState(() {
      _isVerified = true;
    });
    
    HapticFeedback.heavyImpact(); // Boom!
    _successController.forward();
    
    // 3. Wait and navigate
    await Future.delayed(const Duration(milliseconds: 2500));
    Get.offAllNamed('/home');
  }

  @override
  void dispose() {
    _scanController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userName = Get.arguments ?? "Authorized User";

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Extremely dark background
      body: Stack(
        children: [
          // Background subtle glowing radial gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    _isVerified ? Colors.greenAccent.withOpacity(0.15) : AppColors.primaryColor.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  radius: 1.5,
                ),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Identity Graphic
                SizedBox(
                  height: 180,
                  width: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Backdrop glow
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: _isVerified ? 160 : 120,
                        height: _isVerified ? 160 : 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _isVerified ? Colors.greenAccent.withOpacity(0.4) : AppColors.primaryColor.withOpacity(0.4),
                              blurRadius: 50,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      
                      // Glassmorphic Base
                      ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(45),
                              border: Border.all(
                                color: _isVerified ? Colors.greenAccent.withOpacity(0.8) : AppColors.primaryColor.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // The Icon (Fingerprint or Checkmark)
                                _isVerified 
                                  ? ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 75),
                                    )
                                  : Icon(Icons.fingerprint_rounded, color: AppColors.primaryColor.withOpacity(0.6), size: 75),
                                
                                // Scanning Line
                                if (!_isVerified)
                                  AnimatedBuilder(
                                    animation: _scanLineAnimation,
                                    builder: (context, child) {
                                      return Align(
                                        alignment: Alignment(0, _scanLineAnimation.value),
                                        child: Container(
                                          height: 4,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryColor.withOpacity(0.8),
                                                blurRadius: 12,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Text Area
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Scanning Text
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isVerified ? 0.0 : 1.0,
                        child: Column(
                          children: [
                            const Text(
                              "Verifying Identity...",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white70,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 160,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.white10,
                                  color: AppColors.primaryColor,
                                  minHeight: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Success Text
                      if (_isVerified)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                const Text(
                                  "Identity Verified",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Welcome back, $userName",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withOpacity(0.95),
                                        ),
                                      ),
                                    ],
                                  ),
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
        ],
      ),
    );
  }
}
