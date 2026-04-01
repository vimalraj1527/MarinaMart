import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../controllers/location_controller.dart';

class PickLocationView extends StatefulWidget {
  const PickLocationView({super.key});

  @override
  State<PickLocationView> createState() => _PickLocationViewState();
}

class _PickLocationViewState extends State<PickLocationView> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(12.9716, 77.5946); // Default Bangalore
  String _address = "Fetching address...";
  bool _isFetching = false;
  
  final LocationController _locationController = Get.find<LocationController>();

  @override
  void initState() {
    super.initState();
    if (_locationController.currentPosition.value != null) {
      _center = LatLng(
        _locationController.currentPosition.value!.latitude,
        _locationController.currentPosition.value!.longitude,
      );
    }
    _decodeAddress(_center);
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
        title: const Text("Pin Location"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              _center = position.target;
            },
            onCameraIdle: () => _decodeAddress(_center),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
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
                      const Icon(Icons.location_city, color: AppColors.primaryColor, size: 24),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
                  }
                });
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primaryColor),
            ),
          )
        ],
      ),
    );
  }

  void _confirmLocation() {
    final titleController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Save Address As"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: "Title (e.g. Home, Work)"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _locationController.addAddress(titleController.text, _address);
                Get.back(); // close dialog
                Get.back(); // return from location picker
                Get.snackbar("Success", "Address saved!", backgroundColor: Colors.green, colorText: Colors.white);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}
