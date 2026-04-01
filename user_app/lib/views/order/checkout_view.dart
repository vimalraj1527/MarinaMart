import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/location_controller.dart';
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
  
  final _nameController = TextEditingController(text: "Bloomarina Customer");
  final _phoneController = TextEditingController(text: "+91 9999999999");
  String _paymentMethod = "Cash on Delivery";

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
                     onChanged: null, // Disabled for now as per user COD focus
                   ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 4. Bill Details (GST & Total)
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
            
            const SizedBox(height: 100), // Space for button
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

     _cartController.placeOrder(total, _nameController.text, _phoneController.text);
  }
}
