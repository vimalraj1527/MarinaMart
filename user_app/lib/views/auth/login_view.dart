import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_colors.dart';
import 'package:flutter/services.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isOtpLogin = true;
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final size = MediaQuery.of(context).size;

    return Obx(() {
      final activeTheme = themeController.currentTheme;

      final List<Map<String, String>> onboardingData = [
        {
          "title": activeTheme.name == "Amethyst"
              ? "Amethyst Premium"
              : activeTheme.name == "Amber"
                  ? "Amber Express"
                  : activeTheme.name == "Ruby"
                      ? "Ruby Gourmet"
                      : "Emerald Fresh",
          "subtitle": activeTheme.name == "Amethyst"
              ? "Your favorite snacks & essentials delivered in 10 minutes."
              : activeTheme.name == "Amber"
                  ? "From fresh milk to party essentials, delivered in minutes."
                  : activeTheme.name == "Ruby"
                      ? "Craving food or needing groceries? We deliver both instantly."
                      : "Freshness delivered directly to your doorstep.",
          "image": activeTheme.loginBannerUrl,
        },
        {
          "title": "Farm Fresh Produce",
          "subtitle": "Handpicked quality fruits & veggies, guaranteed.",
          "image": "https://images.unsplash.com/photo-1604719312566-8912e9227c6a?auto=format&fit=crop&w=800&q=80",
        },
        {
          "title": "Exclusive Discounts",
          "subtitle": "Save more on your daily household essentials.",
          "image": "https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?auto=format&fit=crop&w=800&q=80",
        },
      ];

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Auto-scrolling Carousel
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.44,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        onboardingData[index]["image"]!,
                        fit: BoxFit.cover,
                      ),
                      // Gradient to make text pop
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.9),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: size.height * 0.08,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [activeTheme.primaryColor, activeTheme.secondaryColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: activeTheme.primaryColor.withOpacity(0.6),
                                      blurRadius: 25,
                                      spreadRadius: 8,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.bolt_rounded,
                                      color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      activeTheme.name == "Amethyst"
                                          ? "AMETHYST INSTANT"
                                          : activeTheme.name == "Amber"
                                              ? "AMBER EXPRESS"
                                              : activeTheme.name == "Ruby"
                                                  ? "RUBY INSTANT"
                                                  : "EMERALD FRESH",
                                      style: TextStyle(
                                        color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              onboardingData[index]["title"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              onboardingData[index]["subtitle"]!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Custom Dots Indicator
            Positioned(
              top: size.height * 0.37,
              left: 24,
              child: Row(
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    height: 6,
                    width: _currentPage == index ? 24 : 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? activeTheme.secondaryColor : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            // Glassmorphic Brand Switcher
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  themeController.showThemeBottomSheet();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.palette_rounded, color: activeTheme.primaryColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            activeTheme.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Glassmorphic Skip Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 24,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.offAllNamed('/home');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Skip",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Permanent Bottom Sheet (Login Card)
            Positioned(
              top: size.height * 0.40,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome to MaRinaMaRt",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isOtpLogin
                                      ? "Sign in instantly via OTP code"
                                      : "Login using your account credentials",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Image.network(
                            activeTheme.logoUrl,
                            height: 42,
                            width: 42,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Login Mode Toggle Tabs (OTP vs Password)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isOtpLogin = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _isOtpLogin ? activeTheme.primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: _isOtpLogin
                                        ? [
                                            BoxShadow(
                                              color: activeTheme.primaryColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.sms_rounded,
                                        size: 16,
                                        color: _isOtpLogin
                                            ? (activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white)
                                            : AppColors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Mobile OTP",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _isOtpLogin
                                              ? (activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white)
                                              : AppColors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isOtpLogin = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !_isOtpLogin ? activeTheme.primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !_isOtpLogin
                                        ? [
                                            BoxShadow(
                                              color: activeTheme.primaryColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock_rounded,
                                        size: 16,
                                        color: !_isOtpLogin
                                            ? (activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white)
                                            : AppColors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Email / Phone",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: !_isOtpLogin
                                              ? (activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white)
                                              : AppColors.grey,
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
                      const SizedBox(height: 16),

                      if (_isOtpLogin) ...[
                        // Mobile OTP Form
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                              fontSize: 16,
                              letterSpacing: 1.0,
                            ),
                            decoration: InputDecoration(
                              hintText: "10-digit Mobile Number",
                              hintStyle: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600, letterSpacing: 0),
                              prefixIcon: Container(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.phone_android_rounded, color: activeTheme.primaryColor, size: 20),
                                    const SizedBox(width: 6),
                                    const Text("+91", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black, fontSize: 15)),
                                    const SizedBox(width: 4),
                                    Container(width: 1, height: 16, color: Colors.grey.shade400),
                                  ],
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                          ),
                        ),
                        
                        if (_otpSent) ...[
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: controller.otpController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                                fontSize: 18,
                                letterSpacing: 6.0,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter 6-digit OTP",
                                hintStyle: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600, letterSpacing: 0, fontSize: 14),
                                prefixIcon: Icon(Icons.shield_outlined, color: activeTheme.primaryColor, size: 22),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        if (!_otpSent)
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () async {
                                      HapticFeedback.selectionClick();
                                      final success = await controller.sendOtp(controller.phoneController.text);
                                      if (success) {
                                        setState(() {
                                          _otpSent = true;
                                        });
                                      }
                                    },
                              icon: const Icon(Icons.send_rounded, size: 18),
                              label: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                    )
                                  : Text(
                                      "Send Verification OTP",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeTheme.primaryColor,
                                foregroundColor: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                textStyle: TextStyle(
                                  inherit: true,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                ),
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () async {
                                            HapticFeedback.selectionClick();
                                            await controller.sendOtp(controller.phoneController.text);
                                          },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: activeTheme.primaryColor, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Text(
                                      "Resend OTP",
                                      style: TextStyle(
                                        color: activeTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : () {
                                            HapticFeedback.selectionClick();
                                            controller.verifyOtpAndLogin(
                                              controller.phoneController.text,
                                              controller.otpController.text,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: activeTheme.primaryColor,
                                      foregroundColor: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                      textStyle: TextStyle(
                                        inherit: true,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                      ),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                          )
                                        : Text(
                                            "Verify & Login",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ] else ...[
                        // Email / Phone & Password Form
                        _buildInputField(
                          controller: controller.emailController,
                          hint: "Email Address or Mobile Number",
                          icon: Icons.person_pin_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: controller.passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: activeTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 14),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value ? null : () {
                              HapticFeedback.selectionClick();
                              controller.login();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeTheme.primaryColor,
                              foregroundColor: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                              textStyle: TextStyle(
                                inherit: true,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                              ),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : Text(
                                    "Login Securely",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 14),

                      // Google Login
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () { HapticFeedback.selectionClick(); },
                          icon: Image.network('https://cdn-icons-png.flaticon.com/512/2991/2991148.png', height: 18),
                          label: const Text(
                            "Continue with Google",
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.greyLight, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      
                      // Register Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Get.toNamed('/signup');
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: activeTheme.primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.black,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600),
          prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

