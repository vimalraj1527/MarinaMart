import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../utils/app_constants.dart';

class LocationController extends GetxController {
  final RxString currentAddress = "Locating...".obs;
  final RxString shortAddress = "Locating...".obs;
  final RxString selectedAddressId = "current".obs;
  final RxList<Map<String, String>> savedAddresses = <Map<String, String>>[].obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  // Calculate distance from Store in KM
  double getDistanceFromStore() {
    if (currentPosition.value == null) {
      // Default mock distance for testing if location is pending
      return 3.2; 
    }
    
    double distanceInMeters = Geolocator.distanceBetween(
      AppConstants.storeLat,
      AppConstants.storeLong,
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
    );
    
    // Return distance in Kilometers
    return (distanceInMeters / 1000).toPrecision(1);
  }

  void addAddress(String title, String address) {
    savedAddresses.add({'id': DateTime.now().toString(), 'title': title, 'address': address});
  }

  void setActiveAddress(String id, String address) {
    selectedAddressId.value = id;
    updateAddressManual(address);
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentAddress.value = "Location services disabled";
        shortAddress.value = "Location Disabled";
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress.value = "Permission denied";
          shortAddress.value = "Access Denied";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentAddress.value = "Permission denied forever";
        shortAddress.value = "Access Denied";
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      currentPosition.value = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String sub = place.subLocality ?? "";
        String loc = place.locality ?? "";
        currentAddress.value = "${place.name ?? ""}, $sub, $loc, ${place.postalCode ?? ""}";
        shortAddress.value = "${sub.isEmpty ? loc : sub}, $loc";
      } else {
        currentAddress.value = "Address not found";
        shortAddress.value = "Unknown Location";
      }

    } catch (e) {
      currentAddress.value = "Error fetching location";
      shortAddress.value = "GPS Error";
      print("Location Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void updateAddressManual(String newAddress) {
    currentAddress.value = newAddress;
    List<String> parts = newAddress.split(',');
    if (parts.length > 1) {
      shortAddress.value = "${parts[0].trim()}, ${parts[1].trim()}";
    } else {
      shortAddress.value = newAddress.length > 20 ? "${newAddress.substring(0, 17)}..." : newAddress;
    }
  }
}
