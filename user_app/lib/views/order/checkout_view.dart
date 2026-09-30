import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/storage_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final CartController _cartController = Get.find<CartController>();
  final LocationController _locationController = Get.find<LocationController>();
  final SettingsController _settings = Get.find<SettingsController>();
  final StorageService _storage = Get.find<StorageService>();
  final AuthController _authController = Get.find<AuthController>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _paymentMethod = "Google Pay / UPI";
  String _deliveryType = "Scheduled";
  DateTime? _scheduledDateTime;
  String? _selectedSlotLabel;
  bool _useWallet = false;
  int _selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    String? userStr = _storage.getUser();
    String name = "MaRinaMaRt Customer";
    String phone = "+91 9999999999";

    if (userStr != null) {
      try {
        final userData = jsonDecode(userStr);
        name = userData['name'] ?? name;
        phone = userData['phone'] ?? phone;
      } catch (e) {
        debugPrint("Error decoding user for checkout: $e");
      }
    }

    _nameController = TextEditingController(text: name);
    _phoneController = TextEditingController(text: phone);

    // Automatically pre-select the first available slot for scheduled delivery
    final availableSlots = _generateAvailableSlots();
    if (availableSlots.isNotEmpty) {
      _scheduledDateTime = availableSlots[0]['dateTime'];
      _selectedSlotLabel = availableSlots[0]['label'];
    }

    // Ensure we have the absolute latest pricing from backend
    _settings.fetchRemoteSettings();
    _authController.refreshUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Generates 2 slots per day for the next 7 days
  List<Map<String, dynamic>> _generateAvailableSlots() {
    List<Map<String, dynamic>> slots = [];
    // Convert current UTC time to Indian Chennai Time (IST)
    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

    for (int i = 0; i < 7; i++) {
      DateTime date = now.add(Duration(days: i));
      String dayLabel = i == 0
          ? "Today"
          : i == 1
          ? "Tomorrow"
          : DateFormat('EEE, MMM d').format(date);

      DateTime morningCutoff = DateTime.utc(date.year, date.month, date.day, 7, 0);

      if (now.isBefore(morningCutoff)) {
        // 8:00 AM Chennai time is 2:30 AM UTC
        DateTime morningStartUtc = DateTime.utc(date.year, date.month, date.day, 8, 0)
            .subtract(const Duration(hours: 5, minutes: 30));
        slots.add({
          'label': '$dayLabel (Morning 8AM-12PM)',
          'dateTime': morningStartUtc,
          'display': 'Morning Slot (8 AM - 12 PM)',
          'dateLabel': dayLabel,
        });
      }

      DateTime eveningCutoff = DateTime.utc(date.year, date.month, date.day, 15, 0);

      if (now.isBefore(eveningCutoff)) {
        // 4:00 PM (16:00) Chennai time is 10:30 AM UTC
        DateTime eveningStartUtc = DateTime.utc(date.year, date.month, date.day, 16, 0)
            .subtract(const Duration(hours: 5, minutes: 30));
        slots.add({
          'label': '$dayLabel (Evening 4PM-8PM)',
          'dateTime': eveningStartUtc,
          'display': 'Evening Slot (4 PM - 8 PM)',
          'dateLabel': dayLabel,
        });
      }
    }
    return slots;
  }

  void _showSlotPicker() {
    final availableSlots = _generateAvailableSlots();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Delivery Slot",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Choose a convenient time for your delivery",
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = availableSlots[index];
                  bool isSelected = _selectedSlotLabel == slot['label'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _scheduledDateTime = slot['dateTime'];
                          _selectedSlotLabel = slot['label'];
                        });
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.05)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey.shade200,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot['dateLabel'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  slot['display'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showInstantConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              "Switch to Instant?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Instant delivery has a delivery charge of ₹50 + ₹5/km. Free delivery thresholds do not apply to Instant delivery.\n\nAre you sure you want to proceed?",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _deliveryType = "Instant";
              });
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Yes, Switch"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  double _calculateDeliveryFee(double subtotal) {
    double? selLat;
    double? selLon;
    if (_locationController.savedAddresses.isNotEmpty &&
        _selectedAddressIndex >= 0 &&
        _selectedAddressIndex < _locationController.savedAddresses.length) {
      final addr = _locationController.savedAddresses[_selectedAddressIndex];
      selLat = double.tryParse(addr['lat']?.toString() ?? '0');
      selLon = double.tryParse(addr['lon']?.toString() ?? '0');
      if (selLat == 0.0) selLat = null;
      if (selLon == 0.0) selLon = null;
    }

    if (_deliveryType == "Instant") {
      double distance = _locationController.getDistanceFromStore(targetLat: selLat, targetLon: selLon);
      double baseFee = _settings.instantBaseFee.value > 0 ? _settings.instantBaseFee.value : 50.0;
      double perKm = _settings.perKmCharge.value > 0 ? _settings.perKmCharge.value : 5.0;
      double fee = baseFee + (distance * perKm);
      return double.parse(fee.toStringAsFixed(2));
    }

    // Free delivery for Scheduled delivery if subtotal reaches threshold
    if (subtotal >= 501.0 || subtotal >= _settings.freeDeliveryThreshold.value) {
      return 0.0;
    }

    return _settings.baseDeliveryCharge.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Final Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Obx(() {
        double? selLat;
        double? selLon;
        if (_locationController.savedAddresses.isNotEmpty &&
            _selectedAddressIndex >= 0 &&
            _selectedAddressIndex < _locationController.savedAddresses.length) {
          final addr = _locationController.savedAddresses[_selectedAddressIndex];
          selLat = double.tryParse(addr['lat']?.toString() ?? '0');
          selLon = double.tryParse(addr['lon']?.toString() ?? '0');
          if (selLat == 0.0) selLat = null;
          if (selLon == 0.0) selLon = null;
        }

        double subtotal = _cartController.totalAmount;
        double gst = subtotal * 0.05;
        double deliveryFee = _calculateDeliveryFee(subtotal);
        double orderTotal = subtotal + gst + deliveryFee;
        double distance = _locationController.getDistanceFromStore(targetLat: selLat, targetLon: selLon);

        double walletBalance =
            double.tryParse(
              _authController.currentUser['walletBalance']?.toString() ?? '0',
            ) ??
            0.0;
        double appliedWalletAmount = _useWallet
            ? (walletBalance >= orderTotal ? orderTotal : walletBalance)
            : 0.0;
        double finalTotal = orderTotal - appliedWalletAmount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Deliver To"),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.primaryColor,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _locationController.displayShortAddress,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _locationController.displayFullAddress,
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/addresses'),
                      child: const Text("CHANGE"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionHeader("Delivery Strategy"),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    RadioListTile(
                      value: "Scheduled",
                      groupValue: _deliveryType,
                      title: const Text(
                        "Scheduled Delivery",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _selectedSlotLabel ??
                            "Flat ₹${_settings.baseDeliveryCharge.value.toInt()} • Choose window",
                      ),
                      secondary: const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                        size: 32,
                      ),
                      activeColor: AppColors.primaryColor,
                      onChanged: (val) {
                        setState(() => _deliveryType = val.toString());
                        if (_scheduledDateTime == null) _showSlotPicker();
                      },
                    ),
                    if (_deliveryType == "Scheduled")
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: _showSlotPicker,
                          icon: const Icon(Icons.edit_calendar, size: 18),
                          label: const Text("Change Delivery Slot"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            side: BorderSide(
                              color: AppColors.primaryColor.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    const Divider(indent: 72),
                    RadioListTile(
                      value: "Instant",
                      groupValue: _deliveryType,
                      title: const Text(
                        "Instant Delivery",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Base ₹${_settings.instantBaseFee.value.toInt()} + ₹${_settings.perKmCharge.value.toInt()}/km • Distance: ${distance.toStringAsFixed(1)} KM (Fee: ₹${_calculateDeliveryFee(subtotal).toInt()})",
                      ),
                      secondary: const Icon(
                        Icons.bolt,
                        color: Colors.amber,
                        size: 32,
                      ),
                      activeColor: AppColors.primaryColor,
                      onChanged: (val) {
                        if (_deliveryType != "Instant") {
                          _showInstantConfirmationDialog();
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionHeader("Contact Details"),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Recipient Name",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const Divider(),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Mobile Contact",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.phone_iphone_outlined),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionHeader("Payment Mode"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: "Google Pay / UPI",
                      groupValue: _paymentMethod,
                      activeColor: const Color(0xFF4285F4),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4285F4).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "GPay / UPI",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Google Pay / Any UPI",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Direct UPI to 9629272964 via GPay / PhonePe / Paytm / QR Code",
                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF4285F4), size: 22),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _paymentMethod = val!;
                        });
                      },
                    ),
                    const Divider(indent: 72, height: 1),
                    RadioListTile<String>(
                      value: "Cash on Delivery",
                      groupValue: _paymentMethod,
                      activeColor: AppColors.primaryColor,
                      title: const Text(
                        "Cash on Delivery (COD)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Pay with cash/UPI at delivery doorstep",
                          style: TextStyle(color: AppColors.grey, fontSize: 12),
                        ),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.handshake_outlined, color: AppColors.primaryColor, size: 22),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _paymentMethod = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionHeader("Wallet Balance"),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SwitchListTile(
                  value: _useWallet,
                  onChanged: walletBalance > 0
                      ? (val) => setState(() => _useWallet = val)
                      : null,
                  activeThumbColor: AppColors.primaryColor,
                  title: const Text(
                    "Apply Wallet Balance",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    walletBalance > 0
                        ? "Use ₹${walletBalance.toStringAsFixed(2)} to reduce payment"
                        : "Balance: ₹0.00 (Go to profile to add money)",
                    style: TextStyle(
                      color: walletBalance > 0
                          ? Colors.green.shade700
                          : AppColors.grey,
                      fontSize: 13,
                    ),
                  ),
                  secondary: Icon(
                    Icons.wallet,
                    color: walletBalance > 0
                        ? AppColors.primaryColor
                        : AppColors.grey,
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionHeader("Financial Summary"),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildBillRow(
                      "Subtotal",
                      "₹${subtotal.toStringAsFixed(2)}",
                    ),
                    _buildBillRow(
                      "Taxes & GST (5%)",
                      "₹${gst.toStringAsFixed(2)}",
                    ),
                    _buildBillRow(
                      _deliveryType == "Instant"
                          ? "Rapid Delivery Fee (${distance.toStringAsFixed(1)} KM)"
                          : "Value Delivery Fee (Slot)",
                      deliveryFee == 0
                          ? "FREE"
                          : "₹${deliveryFee.toStringAsFixed(2)}",
                      isFree: deliveryFee == 0,
                    ),
                    if (deliveryFee > 0 &&
                        _deliveryType != "Instant" &&
                        subtotal < 501.0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Add ₹${(501.0 - subtotal).toStringAsFixed(0)} more for FREE delivery",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_useWallet && appliedWalletAmount > 0) ...[
                      const Divider(),
                      _buildBillRow(
                        "Order Total",
                        "₹${orderTotal.toStringAsFixed(2)}",
                      ),
                      _buildBillRow(
                        "Wallet Balance Applied",
                        "-₹${appliedWalletAmount.toStringAsFixed(2)}",
                        isFree: true,
                      ),
                    ],
                    const Divider(height: 30),
                    _buildBillRow(
                      "TOTAL PAYABLE",
                      "₹${finalTotal.toStringAsFixed(2)}",
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        );
      }),
      bottomSheet: Obx(() {
        double subtotal = _cartController.totalAmount;
        double gst = subtotal * 0.05;
        double deliveryFee = _calculateDeliveryFee(subtotal);
        double orderTotal = subtotal + gst + deliveryFee;

        double walletBalance =
            double.tryParse(
              _authController.currentUser['walletBalance']?.toString() ?? '0',
            ) ??
            0.0;
        double appliedWalletAmount = _useWallet
            ? (walletBalance >= orderTotal ? orderTotal : walletBalance)
            : 0.0;
        double finalTotal = orderTotal - appliedWalletAmount;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _cartController.isLoading.value
                ? null
                : () => _confirmOrder(orderTotal, appliedWalletAmount),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 3,
              shadowColor: AppColors.primaryColor.withOpacity(0.35),
            ),
            child: _cartController.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Confirm Order • ₹${finalTotal.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.grey,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isBold = false,
    bool isFree = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.black : AppColors.grey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 15 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isFree ? Colors.green : Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmOrder(double finalTotal, double walletAmountUsed) {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      Get.snackbar(
        "Details Missing",
        "Please provide recipient contact information.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    String phoneVal = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (phoneVal.length > 10) {
      phoneVal = phoneVal.substring(phoneVal.length - 10);
    }
    if (phoneVal.length != 10) {
      Get.snackbar(
        "Invalid Mobile Number",
        "Mobile number must be exactly 10 digits.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_deliveryType == "Scheduled" && _scheduledDateTime == null) {
      Get.snackbar(
        "Select Slot",
        "A delivery time slot is required for scheduled orders.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      _showSlotPicker();
      return;
    }

    if (_paymentMethod == "Google Pay / UPI" && finalTotal > 0) {
      _showGPayPaymentDialog(finalTotal, walletAmountUsed, phoneVal);
    } else {
      _proceedPlaceOrder(finalTotal, phoneVal, walletAmountUsed);
    }
  }

  void _showGPayPaymentDialog(double amount, double walletAmountUsed, String phoneVal) {
    String upiId = _settings.upiId.value.isNotEmpty ? _settings.upiId.value : "9629272964@paytm";
    if (!upiId.contains('@')) {
      upiId = "$upiId@paytm";
    }
    String upiPhone = _settings.upiPhone.value.isNotEmpty ? _settings.upiPhone.value : "9629272964";
    String upiName = _settings.upiName.value.isNotEmpty ? _settings.upiName.value : "MaRinaMaRt";

    // App-Specific and Standard NPCI Payload Schemas
    String gpayPayload = "tez://upi/pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=${amount.toStringAsFixed(2)}&cu=INR";
    String phonePePayload = "phonepe://pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=${amount.toStringAsFixed(2)}&cu=INR";
    String npciPayload = "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=${amount.toStringAsFixed(2)}&cu=INR&mode=02&purpose=00";

    String activeQrMode = "gpay"; // "gpay", "phonepe", "all"

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          String currentQrPayload;
          if (activeQrMode == "gpay") {
            currentQrPayload = gpayPayload;
          } else if (activeQrMode == "phonepe") {
            currentQrPayload = phonePePayload;
          } else {
            currentQrPayload = npciPayload;
          }

          String qrUrl = _settings.customQrUrl.value.isNotEmpty
              ? _settings.customQrUrl.value
              : "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(currentQrPayload)}";

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF4285F4), size: 24),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "GPay / PhonePe UPI",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Payable Amount:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text("₹${amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("Pay UPI: $upiPhone ($upiId)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4285F4))),
                  const SizedBox(height: 12),
                  // QR Mode Switcher Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("GPay QR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: activeQrMode == "gpay",
                        selectedColor: const Color(0xFF4285F4).withOpacity(0.2),
                        labelStyle: TextStyle(color: activeQrMode == "gpay" ? const Color(0xFF4285F4) : Colors.black87),
                        onSelected: (_) => setDialogState(() => activeQrMode = "gpay"),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text("PhonePe QR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: activeQrMode == "phonepe",
                        selectedColor: const Color(0xFF5F259F).withOpacity(0.2),
                        labelStyle: TextStyle(color: activeQrMode == "phonepe" ? const Color(0xFF5F259F) : Colors.black87),
                        onSelected: (_) => setDialogState(() => activeQrMode = "phonepe"),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text("All UPI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: activeQrMode == "all",
                        selectedColor: Colors.black12,
                        labelStyle: TextStyle(color: activeQrMode == "all" ? Colors.black : Colors.black87),
                        onSelected: (_) => setDialogState(() => activeQrMode = "all"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // QR Code Image
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Image.network(
                      qrUrl,
                      height: 190,
                      width: 190,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeQrMode == "gpay"
                        ? "Scan with Google Pay or Camera to open GPay"
                        : activeQrMode == "phonepe"
                            ? "Scan with PhonePe or Camera to open PhonePe"
                            : "Scan QR with Google Pay, PhonePe, or Paytm",
                    style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  // Direct App Redirection Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Clipboard.setData(ClipboardData(text: upiId));
                            bool launched = false;
                            try {
                              final tezUri = Uri.parse("tez://upi/pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=${amount.toStringAsFixed(2)}&cu=INR");
                              launched = await launchUrl(tezUri, mode: LaunchMode.externalApplication);
                            } catch (_) {}

                            if (!launched) {
                              try {
                                final intentUri = Uri.parse("intent://pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=${amount.toStringAsFixed(2)}&cu=INR#Intent;scheme=upi;package=com.google.android.apps.nbu.paisa.user;end");
                                launched = await launchUrl(intentUri, mode: LaunchMode.externalApplication);
                              } catch (_) {}
                            }

                            Get.snackbar(
                              launched ? "Redirecting to Google Pay" : "UPI ID Copied",
                              launched
                                  ? "Opening Google Pay app..."
                                  : "UPI ID ($upiId) copied! Open Google Pay to paste & pay.",
                              backgroundColor: const Color(0xFF4285F4),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 4),
                            );
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 15),
                          label: const Text("Google Pay", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4285F4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Clipboard.setData(ClipboardData(text: upiId));
                            bool launched = false;
                            try {
                              final phonepeUri = Uri.parse("phonepe://pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=${amount.toStringAsFixed(2)}&cu=INR");
                              launched = await launchUrl(phonepeUri, mode: LaunchMode.externalApplication);
                            } catch (_) {}

                            if (!launched) {
                              try {
                                final intentUri = Uri.parse("intent://pay?pa=$upiId&pn=${Uri.encodeComponent(upiName)}&am=${amount.toStringAsFixed(2)}&cu=INR#Intent;scheme=upi;package=com.phonepe.app;end");
                                launched = await launchUrl(intentUri, mode: LaunchMode.externalApplication);
                              } catch (_) {}
                            }

                            Get.snackbar(
                              launched ? "Redirecting to PhonePe" : "UPI ID Copied",
                              launched
                                  ? "Opening PhonePe app..."
                                  : "UPI ID ($upiId) copied! Open PhonePe to paste & pay.",
                              backgroundColor: const Color(0xFF5F259F),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 4),
                            );
                          },
                          icon: const Icon(Icons.payment_rounded, size: 15),
                          label: const Text("PhonePe", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5F259F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: upiId));
                      Get.snackbar("UPI ID Copied", "UPI ID ($upiId) copied to clipboard!", backgroundColor: Colors.black87, colorText: Colors.white);
                    },
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: Text("Copy UPI ID ($upiId)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _proceedPlaceOrder(amount, phoneVal, walletAmountUsed);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("I Have Paid • Complete Order", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _proceedPlaceOrder(double finalTotal, String phoneVal, double walletAmountUsed) {
    _cartController.placeOrder(
      finalTotal,
      _nameController.text,
      phoneVal,
      deliveryType: _deliveryType,
      scheduledAt: _scheduledDateTime?.toIso8601String(),
      walletAmountUsed: walletAmountUsed,
      paymentMethod: _paymentMethod,
    );
  }
}
