import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/auth_controller.dart';

class PickLocationView extends StatefulWidget {
  const PickLocationView({super.key});

  @override
  State<PickLocationView> createState() => _PickLocationViewState();
}

class _PickLocationViewState extends State<PickLocationView> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(12.9716, 77.5946); // Default Bangalore
  String _address = "Fetching address...";
  bool _isFetching = false;
  
  final LocationController _locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    // Start with current known location if available
    if (_locationController.currentPosition.value != null) {
      _center = LatLng(
        _locationController.currentPosition.value!.latitude,
        _locationController.currentPosition.value!.longitude,
      );
      _decodeAddress(_center);
    } else {
      _locationController.getCurrentLocation().then((_) {
         if (_locationController.currentPosition.value != null) {
           setState(() {
             _center = LatLng(
                _locationController.currentPosition.value!.latitude,
                _locationController.currentPosition.value!.longitude,
             );
           });
           _mapController.move(_center, 15);
           _decodeAddress(_center);
         }
      });
    }
  }

  Future<void> _decodeAddress(LatLng pos) async {
    setState(() => _isFetching = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address = "${place.name ?? ""}, ${place.subLocality ?? ""}, ${place.locality ?? ""}, ${place.postalCode ?? ""}";
        });
      }
    } catch (e) {
      setState(() => _address = "Address not found");
    } finally {
      setState(() => _isFetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pin Location (FREE)"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  _center = pos.center;
                  _decodeAddress(_center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.marinamart.user_app',
              ),
            ],
          ),
          
          // Fixed Center Pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
          ),
          
          // Address Info & Confirm Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Delivery Location", style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_city, color: AppColors.primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _address,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isFetching) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isFetching ? null : _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 3,
                        shadowColor: AppColors.primaryColor.withOpacity(0.35),
                      ),
                      child: const Text("Confirm Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // My Location Button
          Positioned(
            right: 20,
            bottom: 180,
            child: FloatingActionButton(
              onPressed: () {
                _locationController.getCurrentLocation().then((_) {
                  if (_locationController.currentPosition.value != null) {
                    final pos = LatLng(
                      _locationController.currentPosition.value!.latitude,
                      _locationController.currentPosition.value!.longitude
                    );
                    _mapController.move(pos, 15);
                  }
                });
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: AppColors.primaryColor),
            ),
          )
        ],
      ),
    );
  }

  void _confirmLocation() {
    final titleController = TextEditingController(text: "Home");
    final houseController = TextEditingController();
    final landmarkController = TextEditingController();
    
    String userName = "";
    String userPhone = "";
    try {
      final authController = Get.find<AuthController>();
      userName = (authController.currentUser['name'] ?? "").toString();
      userPhone = (authController.currentUser['phone'] ?? "").toString();
    } catch (_) {}

    final nameController = TextEditingController(text: userName);
    final phoneController = TextEditingController(text: userPhone);

    String selectedTag = "Home"; // Active tag chip state

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Address Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: "Outfit",
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Geocoded Address Readonly preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tag selection Swiggy style (Home, Work, Other)
                  const Text("Save Address As", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: ["Home", "Work", "Other"].map((tag) {
                      final isSelected = selectedTag == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                selectedTag = tag;
                                titleController.text = tag;
                              });
                            }
                          },
                          selectedColor: AppColors.primaryColor.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryColor : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // House/Flat/Floor Details
                  TextField(
                    controller: houseController,
                    decoration: InputDecoration(
                      labelText: "House / Flat / Floor / Building *",
                      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Landmark
                  TextField(
                    controller: landmarkController,
                    decoration: InputDecoration(
                      labelText: "Landmark (e.g. Next to Apollo Pharmacy)",
                      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Recipient Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Recipient Name *",
                      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contact Phone Number
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Contact Number *",
                      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Address Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (houseController.text.trim().isEmpty) {
                          Get.snackbar("Required Field", "Please enter House/Flat details", backgroundColor: Colors.redAccent, colorText: Colors.white);
                          return;
                        }
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar("Required Field", "Please enter Recipient Name", backgroundColor: Colors.redAccent, colorText: Colors.white);
                          return;
                        }
                        if (phoneController.text.trim().isEmpty) {
                          Get.snackbar("Required Field", "Please enter Contact Number", backgroundColor: Colors.redAccent, colorText: Colors.white);
                          return;
                        }

                        // Build a detailed final address string
                        final detailedAddress = "${houseController.text.trim()}, $_address"
                            "${landmarkController.text.trim().isNotEmpty ? " (Landmark: ${landmarkController.text.trim()})" : ""}"
                            " | Contact: ${nameController.text.trim()} (${phoneController.text.trim()})";

                        final String id = DateTime.now().millisecondsSinceEpoch.toString();
                        _locationController.savedAddresses.add({
                          'id': id,
                          'title': titleController.text.trim(),
                          'address': detailedAddress,
                        });
                        _locationController.setActiveAddress(id, detailedAddress);
                        
                        Get.back(); // close bottom sheet
                        Get.back(); // return from location picker
                        Get.snackbar("Success", "Address saved!", backgroundColor: Colors.green, colorText: Colors.white);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Save Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      isScrollControlled: true,
    );
  }
}
