import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_colors.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool _otpSent = false;
  bool _isSetupMode = false;
  String _phoneFromArgs = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args != null && args is Map && args['isSetup'] == true) {
        setState(() {
          _isSetupMode = true;
          _phoneFromArgs = args['phone'] ?? '';
          phoneController.text = _phoneFromArgs;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    birthdayController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    
    return Obx(() {
      final activeTheme = themeController.currentTheme;
      final brandName = activeTheme.name;

      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            _isSetupMode 
                ? "Complete Setup" 
                : (brandName == 'Emerald' ? "Join Emerald" : "Create Account"), 
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSetupMode ? "Complete Your Profile" : "Join $brandName",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: activeTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  _isSetupMode
                      ? "Mobile +91 $_phoneFromArgs verified. Enter your details to setup your account."
                      : (brandName == "Ruby" 
                          ? "Order delicious food & groceries instantly." 
                          : "Fresh groceries at your doorstep."),
                  style: const TextStyle(fontSize: 15, color: AppColors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                
                _buildTextField(nameController, "Full Name", Icons.person_outline),
                const SizedBox(height: 14),
                _buildTextField(emailController, "Email Address", Icons.email_outlined),
                const SizedBox(height: 14),
                _buildTextField(
                  phoneController, 
                  "10-Digit Mobile Number", 
                  Icons.phone_android_outlined, 
                  keyboardType: TextInputType.phone,
                  readOnly: _isSetupMode,
                ),
                const SizedBox(height: 14),
                if (!_isSetupMode) ...[
                  _buildTextField(passwordController, "Password", Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 14),
                ],
                _buildTextField(
                  birthdayController, 
                  "Birthday (YYYY-MM-DD)", 
                  Icons.cake_outlined, 
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: activeTheme.primaryColor,
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      birthdayController.text = 
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                
                if (_otpSent && !_isSetupMode) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: activeTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: activeTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.mark_email_read_rounded, color: activeTheme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "SMS OTP Sent",
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Enter the 6-digit OTP code sent to +91 ${phoneController.text}",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: 6,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: "ENTER OTP",
                            hintStyle: const TextStyle(letterSpacing: 1, fontSize: 14, color: AppColors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: activeTheme.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                
                if (_isSetupMode)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty) {
                                Get.snackbar("Name Required", "Please enter your full name.",
                                    backgroundColor: Colors.orange, colorText: Colors.white);
                                return;
                              }
                              if (emailController.text.trim().isEmpty) {
                                Get.snackbar("Email Required", "Please enter your email address.",
                                    backgroundColor: Colors.orange, colorText: Colors.white);
                                return;
                              }
                              final success = await controller.updateProfile(
                                nameController.text.trim(),
                                emailController.text.trim(),
                                phoneController.text.trim(),
                                birthday: birthdayController.text.trim(),
                              );
                              if (success) {
                                Get.offAllNamed('/home');
                                Get.snackbar(
                                  'Setup Complete!',
                                  'Welcome to MaRinaMaRt, ${nameController.text.trim()}!',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              }
                            },
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Finish Setup & Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeTheme.primaryColor,
                        foregroundColor: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        shadowColor: activeTheme.primaryColor.withOpacity(0.35),
                      ),
                    ),
                  )
                else if (!_otpSent)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: controller.isLoading.value 
                            ? null 
                            : () async {
                                String phoneVal = phoneController.text.replaceAll(RegExp(r'\D'), '');
                                if (phoneVal.length > 10) {
                                  phoneVal = phoneVal.substring(phoneVal.length - 10);
                                }
                                if (phoneVal.length != 10) {
                                  Get.snackbar("Invalid Mobile", "Mobile number must be 10 digits.",
                                      backgroundColor: Colors.orange, colorText: Colors.white);
                                  return;
                                }
                                if (nameController.text.trim().isEmpty) {
                                  Get.snackbar("Name Required", "Please enter your full name.",
                                      backgroundColor: Colors.orange, colorText: Colors.white);
                                  return;
                                }
                                if (birthdayController.text.isEmpty) {
                                  Get.snackbar("Birthday Required", "Please select your birthday.",
                                      backgroundColor: Colors.orange, colorText: Colors.white);
                                  return;
                                }
                                final ok = await controller.sendOtp(phoneVal);
                                if (ok) {
                                  setState(() {
                                    _otpSent = true;
                                  });
                                }
                              },
                          icon: const Icon(Icons.sms_rounded, size: 20),
                          label: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Verify via SMS OTP & Register", 
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold,
                                  color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white
                                )
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeTheme.primaryColor,
                            foregroundColor: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 3,
                            shadowColor: activeTheme.primaryColor.withOpacity(0.35),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: controller.isLoading.value
                            ? null
                            : () {
                                String phoneVal = phoneController.text.replaceAll(RegExp(r'\D'), '');
                                if (phoneVal.length > 10) {
                                  phoneVal = phoneVal.substring(phoneVal.length - 10);
                                }
                                controller.register(
                                  nameController.text,
                                  emailController.text,
                                  passwordController.text,
                                  phoneVal,
                                  birthdayController.text,
                                );
                              },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: activeTheme.primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            "Register without OTP",
                            style: TextStyle(
                              color: activeTheme.primaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    final phoneVal = phoneController.text.replaceAll(RegExp(r'\D'), '');
                                    await controller.sendOtp(phoneVal);
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
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    final phoneVal = phoneController.text.replaceAll(RegExp(r'\D'), '');
                                    controller.verifyOtpAndLogin(
                                      phoneVal,
                                      otpController.text,
                                      signupData: {
                                        'name': nameController.text.trim(),
                                        'email': emailController.text.trim(),
                                        'password': passwordController.text.trim(),
                                        'phone': phoneVal,
                                        'birthday': birthdayController.text.trim(),
                                      },
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeTheme.primaryColor,
                              foregroundColor: Colors.white,
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
                                    "Verify & Complete",
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
                
                const SizedBox(height: 24),
                
                if (!_isSetupMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          "Login",
                          style: TextStyle(color: activeTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String hint, 
    IconData icon, {
    bool isPassword = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
