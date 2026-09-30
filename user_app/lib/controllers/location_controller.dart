import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../utils/app_constants.dart';
import 'settings_controller.dart';

class LocationController extends GetxController {
  final RxString currentAddress = "Locating your exact address...".obs;
  final RxString shortAddress = "Locating...".obs;
  final RxString selectedAddressId = "current".obs;
  final RxList<Map<String, String>> savedAddresses = <Map<String, String>>[].obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUserSelected = false.obs;
  
  final RxList<Map<String, dynamic>> searchSuggestions = <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;

  String formatShortArea(String rawStr) {
    if (rawStr.trim().isEmpty) return "Current Location";
    if (rawStr.contains(RegExp(r'^\s*-?\d+\.\d+,\s*-?\d+\.\d+\s*$')) || rawStr.startsWith("Lat:")) {
      return "Current Location";
    }

    List<String> parts = rawStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    List<String> cleanParts = [];
    for (var part in parts) {
      if (RegExp(r'^\d{5,6}$').hasMatch(part)) continue;
      if (part.toLowerCase() == 'india' || part.toLowerCase() == 'united states') continue;
      cleanParts.add(part);
    }

    if (cleanParts.isEmpty) return "Current Location";
    if (cleanParts.length == 1) {
      return cleanParts[0].length > 28 ? "${cleanParts[0].substring(0, 25)}..." : cleanParts[0];
    }
    
    String result = "${cleanParts[0]}, ${cleanParts[1]}";
    if (result.length > 32) {
      return cleanParts[0].length > 25 ? "${cleanParts[0].substring(0, 22)}..." : cleanParts[0];
    }
    return result;
  }

  String get displayShortAddress {
    return formatShortArea(shortAddress.value);
  }

  String get displayFullAddress {
    final val = currentAddress.value.trim();
    if (val.isEmpty || val.contains(RegExp(r'^\s*-?\d+\.\d+,\s*-?\d+\.\d+\s*$')) || val.startsWith("Lat:")) {
      return "Current Location, Delivery Hub";
    }
    return val;
  }

  @override
  void onInit() {
    super.onInit();
    _loadPersistedLocation();
    Future.microtask(() => getCurrentLocation());
  }

  void _loadPersistedLocation() {
    try {
      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        
        // Load Saved Addresses List
        List<Map<String, String>> storedList = storage.getSavedAddresses();
        if (storedList.isNotEmpty) {
          savedAddresses.assignAll(storedList);
        }

        // Load Active User Location
        final saved = storage.getUserLocation();
        if (saved != null) {
          shortAddress.value = saved['short'];
          currentAddress.value = saved['full'];
          isUserSelected.value = true;
          double lat = saved['lat'];
          double lon = saved['lon'];
          if (lat != 0.0 && lon != 0.0) {
            currentPosition.value = Position(
              latitude: lat,
              longitude: lon,
              timestamp: DateTime.now(),
              accuracy: 10,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
          }
        }
      }
    } catch (e) {
      print("Load persisted location error: $e");
    }
  }

  void _persistLocation() {
    try {
      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        double lat = currentPosition.value?.latitude ?? 0.0;
        double lon = currentPosition.value?.longitude ?? 0.0;
        storage.saveUserLocation(shortAddress.value, currentAddress.value, lat, lon);
      }
    } catch (e) {
      print("Persist location error: $e");
    }
  }

  void _persistSavedAddresses() {
    try {
      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        storage.saveSavedAddresses(savedAddresses.toList());
      }
    } catch (e) {
      print("Persist saved addresses error: $e");
    }
  }

  // Calculate exact distance from Store to User Location in KM for delivery fee calculation
  double getDistanceFromStore({double? targetLat, double? targetLon}) {
    final settings = Get.find<SettingsController>();
    double storeLat = settings.storeLat.value > 0 ? settings.storeLat.value : AppConstants.storeLat;
    double storeLong = settings.storeLong.value > 0 ? settings.storeLong.value : AppConstants.storeLong;

    double userLat = targetLat ?? currentPosition.value?.latitude ?? 0.0;
    double userLong = targetLon ?? currentPosition.value?.longitude ?? 0.0;

    // Fallback to saved addresses if live position is empty
    if (userLat == 0.0 || userLong == 0.0) {
      if (savedAddresses.isNotEmpty) {
        userLat = double.tryParse(savedAddresses.first['lat']?.toString() ?? '0') ?? 0.0;
        userLong = double.tryParse(savedAddresses.first['lon']?.toString() ?? '0') ?? 0.0;
      }
    }

    if (userLat == 0.0 || userLong == 0.0) {
      return 2.5; // Fallback distance in KM if GPS is disabled and no address saved
    }

    double distanceInMeters = Geolocator.distanceBetween(
      storeLat,
      storeLong,
      userLat,
      userLong,
    );
    
    double distanceInKm = distanceInMeters / 1000.0;
    
    if (distanceInKm < 0.2) {
      return 1.0;
    }
    
    return double.parse(distanceInKm.toStringAsFixed(1));
  }

  void addAddress(String title, String address, {double? lat, double? lon}) {
    double useLat = lat ?? currentPosition.value?.latitude ?? 0.0;
    double useLon = lon ?? currentPosition.value?.longitude ?? 0.0;
    String id = DateTime.now().millisecondsSinceEpoch.toString();

    savedAddresses.add({
      'id': id,
      'title': title,
      'address': address,
      'lat': useLat.toString(),
      'lon': useLon.toString(),
    });
    _persistSavedAddresses();
  }

  void setActiveAddress(String id, String address, {double? lat, double? lon}) {
    selectedAddressId.value = id;
    isUserSelected.value = true;
    
    if (lat == null || lon == null || lat == 0.0 || lon == 0.0) {
      final match = savedAddresses.firstWhereOrNull((element) => element['id'] == id);
      if (match != null) {
        lat = double.tryParse(match['lat'] ?? '0') ?? 0.0;
        lon = double.tryParse(match['lon'] ?? '0') ?? 0.0;
      }
    }

    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      currentPosition.value = Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    updateAddressManual(address);
  }

  Future<void> searchLocations(String query) async {
    if (query.trim().length < 2) {
      searchSuggestions.clear();
      return;
    }
    try {
      isSearching.value = true;
      final uri = Uri.parse('https://nominatim.openstreetmap.org/search?format=jsonv2&q=${Uri.encodeComponent(query)}&addressdetails=1&limit=5');
      final res = await http.get(uri, headers: {'User-Agent': 'MaRinaMaRtApp/1.0'}).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        searchSuggestions.value = data.map<Map<String, dynamic>>((item) {
          final addr = item['address'] ?? {};
          String name = item['display_name'] ?? "";
          String area = addr['suburb'] ?? addr['neighbourhood'] ?? addr['residential'] ?? addr['road'] ?? addr['city'] ?? addr['town'] ?? "";
          String city = addr['city'] ?? addr['town'] ?? addr['county'] ?? addr['state'] ?? "";
          String title = area.isNotEmpty ? (city.isNotEmpty && city != area ? "$area, $city" : area) : name.split(',').first;
          return {
            'title': title,
            'full_address': name,
            'lat': double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0,
            'lon': double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0,
          };
        }).toList();
      }
    } catch (e) {
      print("Location search error: $e");
    } finally {
      isSearching.value = false;
    }
  }

  void selectSearchResult(Map<String, dynamic> result) {
    String title = result['title'] ?? "";
    String full = result['full_address'] ?? title;
    double lat = result['lat'] ?? 0.0;
    double lon = result['lon'] ?? 0.0;

    if (lat != 0.0 && lon != 0.0) {
      currentPosition.value = Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    shortAddress.value = title;
    currentAddress.value = full;
    selectedAddressId.value = 'search';
    isUserSelected.value = true;
    searchSuggestions.clear();
    _persistLocation();
  }

  Future<void> getCurrentLocation({bool forceRefresh = false}) async {
    // If user has explicitly selected a location and we are not forcing refresh, keep user location
    if (isUserSelected.value && !forceRefresh) {
      return;
    }

    try {
      isLoading.value = true;
      Position? position;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(const Duration(seconds: 2));
        LocationPermission permission = await Geolocator.checkPermission().timeout(const Duration(seconds: 2));
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission().timeout(const Duration(seconds: 3));
        }
        if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(const Duration(seconds: 4));
        }
      } catch (e) {
        print("Geolocator Web non-blocking: $e");
      }

      if (position != null) {
        currentPosition.value = position;
      }

      bool geocoded = false;

      // Method 1: OpenStreetMap Nominatim Exact Street Level Reverse Geocoding
      if (position != null) {
        try {
          final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1');
          final res = await http.get(uri, headers: {'User-Agent': 'MaRinaMaRtApp/1.0'}).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            final addr = data['address'] ?? {};
            String road = addr['road'] ?? addr['pedestrian'] ?? addr['street'] ?? "";
            String sub = addr['suburb'] ?? addr['neighbourhood'] ?? addr['residential'] ?? addr['subdistrict'] ?? addr['quarter'] ?? "";
            String city = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['county'] ?? addr['state_district'] ?? addr['state'] ?? "";
            String postcode = addr['postcode'] ?? "";

            String area = sub.isNotEmpty ? sub : (road.isNotEmpty ? road : city);
            String secondary = city.isNotEmpty && city != area ? city : "";

            if (area.isNotEmpty) {
              shortAddress.value = secondary.isNotEmpty ? "$area, $secondary" : area;
              
              List<String> fullParts = [];
              if (road.isNotEmpty) fullParts.add(road);
              if (sub.isNotEmpty && sub != road) fullParts.add(sub);
              if (city.isNotEmpty && city != sub) fullParts.add(city);
              if (postcode.isNotEmpty) fullParts.add(postcode);

              currentAddress.value = fullParts.isNotEmpty ? fullParts.join(", ") : (data['display_name'] ?? shortAddress.value);
              geocoded = true;
              _persistLocation();
            }
          }
        } catch (e) {
          print("OSM Reverse Geocode error: $e");
        }
      }

      // Method 2: BigDataCloud Universal Geocode Fallback
      if (!geocoded) {
        try {
          String apiUrl = 'https://api.bigdatacloud.net/data/reverse-geocode-client?localityLanguage=en';
          if (position != null) {
            apiUrl += '&latitude=${position.latitude}&longitude=${position.longitude}';
          }
          
          final res = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            String locality = data['locality']?.toString() ?? "";
            String city = data['city']?.toString() ?? data['principalSubdivision'] ?? "";
            String state = data['principalSubdivision']?.toString() ?? "";

            String area = locality.isNotEmpty ? locality : (city.isNotEmpty ? city : state);
            String secondary = city.isNotEmpty && city != area ? city : (state.isNotEmpty && state != area ? state : "");

            if (area.isNotEmpty) {
              shortAddress.value = secondary.isNotEmpty ? "$area, $secondary" : area;
              currentAddress.value = [area, secondary, data['countryName']].where((s) => s != null && s.toString().isNotEmpty).join(", ");
              geocoded = true;
              _persistLocation();
            }
          }
        } catch (e) {
          print("BigDataCloud Geocode error: $e");
        }
      }

      if (!geocoded && shortAddress.value == "Locating...") {
        shortAddress.value = "Current Location";
        currentAddress.value = "Current Location, Delivery Hub";
      }

    } catch (e) {
      if (shortAddress.value == "Locating...") {
        currentAddress.value = "Current Location, Delivery Hub";
        shortAddress.value = "Current Location";
      }
      print("Location Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void updateAddressManual(String newAddress) {
    if (newAddress.contains(RegExp(r'^\s*-?\d+\.\d+,\s*-?\d+\.\d+\s*$')) || newAddress.startsWith("Lat:")) {
      currentAddress.value = "Marina Zone, Central Delivery Hub";
      shortAddress.value = "Marina Zone, Central";
      _persistLocation();
      return;
    }

    currentAddress.value = newAddress;
    List<String> parts = newAddress.split(',');
    if (parts.length > 1) {
      shortAddress.value = "${parts[0].trim()}, ${parts[1].trim()}";
    } else {
      shortAddress.value = newAddress.length > 25 ? "${newAddress.substring(0, 22)}..." : newAddress;
    }
    _persistLocation();
  }
}
