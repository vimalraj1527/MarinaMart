import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/order_model.dart';
import '../../controllers/location_controller.dart';
import '../../utils/app_colors.dart';

class TrackOrderView extends StatelessWidget {
  const TrackOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel order = Get.arguments;
    final LocationController locController = Get.find<LocationController>();
    
    // Ordered Address Position: Using current location as the target for this demo
    final LatLng destinationPos = locController.currentPosition.value != null 
        ? LatLng(locController.currentPosition.value!.latitude, locController.currentPosition.value!.longitude)
        : const LatLng(12.9716, 77.5946); // Fallback to Bangalore default

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Order Location: ${order.orderNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Map focusing on Customer Location
          FlutterMap(
            options: MapOptions(
              initialCenter: destinationPos,
              initialZoom: 16
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bloomarina.instamart.user_app',
              ),
              MarkerLayer(
                markers: [
                  // Destination Marker (Customer)
                  Marker(
                    point: destinationPos,
                    width: 80,
                    height: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                          child: const Text("DELIVER HERE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                        const Icon(Icons.location_on_rounded, color: Colors.red, size: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Address Details Overlay
          Positioned(
            top: 20, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95), 
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("DELIVERY ADDRESS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.grey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.home_filled, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(order.deliveryAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Status Panel
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Delivery Status", style: TextStyle(color: AppColors.grey, fontSize: 12)),
                          Text(order.status == "Pending" ? "Confirmed" : order.status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green.shade700)),
                        ],
                      ),
                      Icon(Icons.shopping_bag_outlined, color: AppColors.primaryColor, size: 30),
                    ],
                  ),
                  const Divider(height: 40),
                  _buildTrackStep("Order Confirmed", "Successfully placed and verified", true),
                  _buildTrackStep("Store Preparing", "Checking quality and packing items", order.status == "Processing" || order.status == "Out for Delivery" || order.status == "Delivered"),
                  _buildTrackStep("On the Way", "Rider is delivering to your location", order.status == "Out for Delivery" || order.status == "Delivered"),
                  _buildTrackStep("Delivered", "Enjoy your fresh groceries!", order.status == "Delivered"),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text("CLOSE", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStep(String title, String subtitle, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(isCompleted ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: isCompleted ? Colors.green : AppColors.greyLight, size: 20),
          const SizedBox(width: 15),
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isCompleted ? Colors.black : AppColors.grey)),
               Text(subtitle, style: TextStyle(fontSize: 11, color: isCompleted ? AppColors.grey : AppColors.greyLight)),
             ],
          ),
        ],
      ),
    );
  }
}
