import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/settings_controller.dart';
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
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _paymentMethod = "Cash on Delivery";
  String _deliveryType = "Instant";
  DateTime? _scheduledDateTime;
  String? _selectedSlotLabel;

  @override
  void initState() {
    super.initState();
    String? userStr = _storage.getUser();
    String name = "Bloomarina Customer";
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

    // Ensure we have the absolute latest pricing from backend
    _settings.fetchRemoteSettings();
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
    DateTime now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
       DateTime date = now.add(Duration(days: i));
       String dayLabel = i == 0 ? "Today" : i == 1 ? "Tomorrow" : DateFormat('EEE, MMM d').format(date);
       
       DateTime morningStart = DateTime(date.year, date.month, date.day, 8, 0);
       DateTime morningCutoff = DateTime(date.year, date.month, date.day, 7, 0);
       
       if (now.isBefore(morningCutoff)) {
          slots.add({
            'label': '$dayLabel (Morning 8AM-12PM)',
            'dateTime': morningStart,
            'display': 'Morning Slot (8 AM - 12 PM)',
            'dateLabel': dayLabel,
          });
       }

       DateTime eveningStart = DateTime(date.year, date.month, date.day, 16, 0);
       DateTime eveningCutoff = DateTime(date.year, date.month, date.day, 15, 0);

       if (now.isBefore(eveningCutoff)) {
          slots.add({
            'label': '$dayLabel (Evening 4PM-8PM)',
            'dateTime': eveningStart,
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
            const Text("Select Delivery Slot", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Choose a convenient time for your delivery", style: TextStyle(color: AppColors.grey)),
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
                          color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : Colors.white,
                          border: Border.all(color: isSelected ? AppColors.primaryColor : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(slot['dateLabel'], style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primaryColor : Colors.black87)),
                                const SizedBox(height: 2),
                                Text(slot['display'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                            if (isSelected) Icon(Icons.check_circle, color: AppColors.primaryColor)
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

  double _calculateDeliveryFee(double subtotal) {
    if (_deliveryType == "Instant") {
      double distance = _locationController.getDistanceFromStore();
      return _settings.instantBaseFee.value + (distance * _settings.perKmCharge.value);
    }

    if (subtotal >= _settings.freeDeliveryThreshold.value) {
      return 0.0;
    }
    
    return _settings.baseDeliveryCharge.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Final Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Obx(() {
        double subtotal = _cartController.totalAmount;
        double gst = subtotal * 0.05;
        double deliveryFee = _calculateDeliveryFee(subtotal);
        double total = subtotal + gst + deliveryFee;
        double distance = _locationController.getDistanceFromStore();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Deliver To"),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                     Icon(Icons.location_on, color: AppColors.primaryColor, size: 30),
                     const SizedBox(width: 15),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(_locationController.shortAddress.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           const SizedBox(height: 4),
                           Text(_locationController.currentAddress.value, style: const TextStyle(color: AppColors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                         ],
                       ),
                     ),
                     TextButton(onPressed: () => Get.toNamed('/addresses'), child: const Text("CHANGE")),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),

              _buildSectionHeader("Delivery Strategy"),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                     RadioListTile(
                       value: "Instant",
                       groupValue: _deliveryType,
                       title: const Text("Instant Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
                       subtitle: Text("₹${_settings.instantBaseFee.value.toInt()} + ₹${_settings.perKmCharge.value.toInt()}/km • Nearby: ${distance.toStringAsFixed(1)} KM"),
                       secondary: const Icon(Icons.bolt, color: Colors.amber, size: 32),
                       activeColor: AppColors.primaryColor,
                       onChanged: (val) => setState(() => _deliveryType = val.toString()),
                     ),
                     const Divider(indent: 72),
                     RadioListTile(
                       value: "Scheduled",
                       groupValue: _deliveryType,
                       title: const Text("Scheduled Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
                       subtitle: Text(_selectedSlotLabel ?? "Flat ₹${_settings.baseDeliveryCharge.value.toInt()} • Choose window"),
                       secondary: const Icon(Icons.calendar_month, color: Colors.blue, size: 32),
                       activeColor: AppColors.primaryColor,
                       onChanged: (val) {
                          setState(() => _deliveryType = val.toString());
                          if (_scheduledDateTime == null) _showSlotPicker();
                       },
                     ),
                     if (_deliveryType == "Scheduled")
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                         child: OutlinedButton.icon(
                           onPressed: _showSlotPicker,
                           icon: const Icon(Icons.edit_calendar, size: 18),
                           label: const Text("Change Delivery Slot"),
                           style: OutlinedButton.styleFrom(
                             minimumSize: const Size(double.infinity, 45),
                             side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                         ),
                       ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              
              _buildSectionHeader("Contact Details"),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Recipient Name", border: InputBorder.none, prefixIcon: Icon(Icons.person_outline)),
                    ),
                    const Divider(),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Mobile Contact", border: InputBorder.none, prefixIcon: Icon(Icons.phone_iphone_outlined)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionHeader("Payment Mode"),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                     RadioListTile(
                       value: "Cash on Delivery",
                       groupValue: _paymentMethod,
                       title: const Text("Cash on Delivery (COD)"),
                       subtitle: const Text("Physical payment at doorstep"),
                       activeColor: AppColors.primaryColor,
                       onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                     ),
                     RadioListTile(
                       value: "Online",
                       groupValue: _paymentMethod,
                       title: Row(
                         children: [
                           const Text("Secure Online Payment"),
                           const SizedBox(width: 8),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(
                               color: AppColors.primaryColor.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(6),
                             ),
                             child: Text("COMING SOON", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                           )
                         ],
                       ),
                       subtitle: const Text("UPI, Cards, & Wallets"),
                       activeColor: AppColors.primaryColor,
                       onChanged: (val) {
                         Get.snackbar("Coming Soon", "Online payments will be available shortly!", backgroundColor: Colors.black87, colorText: Colors.white);
                       },
                     ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              _buildSectionHeader("Financial Summary"),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    _buildBillRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),
                    _buildBillRow("Taxes & GST (5%)", "₹${gst.toStringAsFixed(2)}"),
                    _buildBillRow(
                      _deliveryType == "Instant" ? "Rapid Delivery Fee (${distance.toStringAsFixed(1)} KM)" : "Value Delivery Fee (Slot)", 
                      deliveryFee == 0 ? "FREE" : "₹${deliveryFee.toStringAsFixed(2)}", 
                      isFree: deliveryFee == 0
                    ),
                    if (deliveryFee > 0 && subtotal < _settings.freeDeliveryThreshold.value)
                       Padding(
                         padding: const EdgeInsets.only(top: 8),
                         child: Text(
                           "Add ₹${(_settings.freeDeliveryThreshold.value - subtotal).toStringAsFixed(0)} more for FREE delivery", 
                           style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)
                         ),
                       ),
                    const Divider(height: 30),
                    _buildBillRow("TOTAL PAYABLE", "₹${total.toStringAsFixed(2)}", isBold: true),
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
        double deliveryFee = _calculateDeliveryFee(subtotal);
        double total = subtotal + (subtotal * 0.05) + deliveryFee;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: ElevatedButton(
            onPressed: _cartController.isLoading.value ? null : () => _confirmOrder(total),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: _cartController.isLoading.value 
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Confirm Order • ₹${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.grey, letterSpacing: 1.5)),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isBold = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? Colors.black : AppColors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 15 : 14)),
          Text(value, style: TextStyle(color: isFree ? Colors.green : Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: isBold ? 17 : 14)),
        ],
      ),
    );
  }

  void _confirmOrder(double total) {
     if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
       Get.snackbar("Details Missing", "Please provide recipient contact information.");
       return;
     }

     if (_deliveryType == "Scheduled" && _scheduledDateTime == null) {
       Get.snackbar("Select Slot", "A delivery time slot is required for scheduled orders.");
       _showSlotPicker();
       return;
     }

     _cartController.placeOrder(
       total, 
       _nameController.text, 
       _phoneController.text,
       deliveryType: _deliveryType,
       scheduledAt: _scheduledDateTime?.toIso8601String(),
     );
  }
}
