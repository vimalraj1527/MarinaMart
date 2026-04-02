import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/location_controller.dart';
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
  final StorageService _storage = Get.find<StorageService>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String _paymentMethod = "Cash on Delivery";
  String _deliveryType = "Instant";
  DateTime? _scheduledDateTime;

  @override
  void initState() {
    super.initState();
    
    // Initialize with user profile data
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _scheduledDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bill Calculation
    double subtotal = _cartController.totalAmount;
    double gst = subtotal * 0.05; // 5% GST
    double deliveryFee = subtotal > 499 ? 0 : 40;
    double total = subtotal + gst + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Final Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Address Summary
            _buildSectionHeader("Deliver To"),
            Obx(() => Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                   const Icon(Icons.location_on, color: AppColors.primaryColor, size: 30),
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
            )),
            
            const SizedBox(height: 25),

            // **NEW: Delivery Strategy**
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
                     subtitle: const Text("Delivery in 15-20 mins"),
                     secondary: const Icon(Icons.bolt, color: Colors.amber),
                     activeColor: AppColors.primaryColor,
                     onChanged: (val) => setState(() => _deliveryType = val.toString()),
                   ),
                   const Divider(indent: 70),
                   RadioListTile(
                     value: "Scheduled",
                     groupValue: _deliveryType,
                     title: const Text("Scheduled Delivery", style: TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: Text(_scheduledDateTime == null ? "Pick a date & time" : DateFormat('EEE, MMM d – hh:mm a').format(_scheduledDateTime!)),
                     secondary: const Icon(Icons.calendar_today, color: Colors.blue),
                     activeColor: AppColors.primaryColor,
                     onChanged: (val) {
                        setState(() => _deliveryType = val.toString());
                        if (_scheduledDateTime == null) _selectDateTime(context);
                     },
                   ),
                   if (_deliveryType == "Scheduled")
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                       child: OutlinedButton.icon(
                         onPressed: () => _selectDateTime(context),
                         icon: const Icon(Icons.edit_calendar, size: 18),
                         label: const Text("Change Schedule"),
                         style: OutlinedButton.styleFrom(
                           minimumSize: const Size(double.infinity, 45),
                           side: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
                         ),
                       ),
                     ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            
            // 2. Contact Details
            _buildSectionHeader("Contact Details"),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Deliver to Whom?", border: InputBorder.none, prefixIcon: Icon(Icons.person_outline)),
                  ),
                  const Divider(),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Mobile Number", border: InputBorder.none, prefixIcon: Icon(Icons.phone_iphone_outlined)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. Payment Method
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
                     subtitle: const Text("Pay at your doorstep"),
                     activeColor: AppColors.primaryColor,
                     onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                   ),
                   RadioListTile(
                     value: "Online",
                     groupValue: _paymentMethod,
                     title: const Text("Online Payment"),
                     subtitle: const Text("UPI, Card, Wallet"),
                     onChanged: null,
                   ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 4. Bill Details
            _buildSectionHeader("Bill Details"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildBillRow("Item Total", "₹${subtotal.toStringAsFixed(2)}"),
                  _buildBillRow("Handling Fee & GST (5%)", "₹${gst.toStringAsFixed(2)}"),
                  _buildBillRow("Delivery Fee", deliveryFee == 0 ? "FREE" : "₹${deliveryFee.toStringAsFixed(2)}", isFree: deliveryFee == 0),
                  const Divider(height: 30),
                  _buildBillRow("To Pay", "₹${total.toStringAsFixed(2)}", isBold: true),
                ],
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Obx(() => ElevatedButton(
          onPressed: _cartController.isLoading.value ? null : () => _confirmOrder(total),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: _cartController.isLoading.value 
            ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Place Order for ₹${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 10),
                  const Icon(Icons.check_circle_rounded),
                ],
              ),
        )),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.grey, letterSpacing: 1.2)),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isBold = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? Colors.black : AppColors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
          Text(value, style: TextStyle(color: isFree ? Colors.green : Colors.black, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  void _confirmOrder(double total) {
     if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
       Get.snackbar("Missing Details", "Please provide delivery contact info.");
       return;
     }

     if (_deliveryType == "Scheduled" && _scheduledDateTime == null) {
       Get.snackbar("Schedule Required", "Please pick a date & time for delivery.");
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
