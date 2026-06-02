import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_colors.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController birthdayController = TextEditingController();

    return Obx(() {
      final activeTheme = themeController.currentTheme;
      final brandName = activeTheme.name;

      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            brandName == 'Emerald' ? "Join Emerald" : "Create Account", 
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
                  "Join $brandName",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  brandName == "Ruby" 
                      ? "Order delicious food & groceries instantly." 
                      : "Fresh groceries at your doorstep.",
                  style: const TextStyle(fontSize: 16, color: AppColors.grey),
                ),
                const SizedBox(height: 32),
                
                _buildTextField(nameController, "Full Name", Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(emailController, "Email Address", Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField(phoneController, "Phone Number", Icons.phone_android_outlined),
                const SizedBox(height: 16),
                _buildTextField(passwordController, "Password", Icons.lock_outline, isPassword: true),
                const SizedBox(height: 16),
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
                              primary: AppColors.primaryColor,
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
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value 
                      ? null 
                      : () {
                          String phoneVal = phoneController.text.replaceAll(RegExp(r'\D'), '');
                          if (phoneVal.length > 10) {
                            phoneVal = phoneVal.substring(phoneVal.length - 10);
                          }
                          if (phoneVal.length != 10) {
                            Get.snackbar("Invalid Mobile Number", "Mobile number must be exactly 10 digits.",
                                backgroundColor: Colors.orange, colorText: Colors.white);
                            return;
                          }
                          if (birthdayController.text.isEmpty) {
                            Get.snackbar("Birthday Required", "Please select your birthday.",
                                backgroundColor: Colors.orange, colorText: Colors.white);
                            return;
                          }
                          controller.register(
                            nameController.text,
                            emailController.text,
                            passwordController.text,
                            phoneVal,
                            birthdayController.text,
                          );
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 3,
                      shadowColor: AppColors.primaryColor.withOpacity(0.35),
                    ),
                    child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Register Now", 
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: activeTheme.name == 'Emerald' ? Colors.black87 : Colors.white
                          )
                        ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        "Login",
                        style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
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
    hint, 
    IconData icon, {
    bool isPassword = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
