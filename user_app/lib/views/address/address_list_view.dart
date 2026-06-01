import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../controllers/location_controller.dart';

class AddressListView extends StatelessWidget {
  const AddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationController location = Get.find<LocationController>();

    return Scaffold(
      appBar: AppBar(title: const Text("My Addresses")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => GestureDetector(
              onTap: () => location.setActiveAddress("current", location.currentAddress.value),
              child: _buildAddressCard("Current Location", location.currentAddress.value, location.selectedAddressId.value == "current")
            )),
            
            // Dynamic saved addresses
            Obx(() => Column(
              children: location.savedAddresses.map((addr) => 
                GestureDetector(
                  onTap: () => location.setActiveAddress(addr['id']!, addr['address']!),
                  child: _buildAddressCard(addr['title'] ?? "", addr['address'] ?? "", location.selectedAddressId.value == addr['id'])
                )
              ).toList(),
            )),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/pick-location'),
                  icon: const Icon(Icons.add),
                  label: const Text("Add New Address"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                    shadowColor: AppColors.primaryColor.withOpacity(0.35),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAddressCard(String title, String address, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.primaryColor, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: isSelected ? AppColors.primaryColor : AppColors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (isSelected) Icon(Icons.check_circle, color: AppColors.primaryColor),
        ],
      ),
    );
  }
}
