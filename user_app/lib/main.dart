import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';
import 'utils/app_constants.dart';
import 'bindings/initial_binding.dart';
import 'services/storage_service.dart';
import 'views/splash/splash_view.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'views/user_info/profile_view.dart';
import 'views/order/orders_view.dart';
import 'views/address/address_list_view.dart';
import 'views/payment/payment_methods_view.dart';
import 'views/notifications/notifications_view.dart';
import 'views/support/support_view.dart';
import 'views/about/about_view.dart';
import 'views/address/pick_location_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Storage initialization
  final storage = StorageService();
  await storage.init();
  Get.put(storage, permanent: true);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
        ),
        useMaterial3: true,
      ),
      initialBinding: InitialBinding(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashView()),
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/home', page: () => const HomeView()),
        GetPage(name: '/profile', page: () => const ProfileView()),
        GetPage(name: '/orders', page: () => const OrdersView()),
        GetPage(name: '/addresses', page: () => const AddressListView()),
        GetPage(name: '/payments', page: () => const PaymentMethodsView()),
        GetPage(name: '/notifications', page: () => const NotificationsView()),
        GetPage(name: '/support', page: () => const SupportView()),
        GetPage(name: '/about', page: () => const AboutView()),
        GetPage(name: '/pick-location', page: () => const PickLocationView()),
      ],
    );
  }
}
