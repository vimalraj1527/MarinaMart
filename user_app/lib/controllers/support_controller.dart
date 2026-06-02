import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';

class SupportController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<dynamic> messages = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  Timer? _pollingTimer;

  // Static support number for WhatsApp
  final String supportPhoneNumber = "9629272964"; 

  Future<void> fetchMessages() async {
    try {
      final response = await _apiService.getData(AppConstants.supportMessagesUrl);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        messages.assignAll(data);
      }
    } catch (e) {
      print("Error fetching support messages: $e");
    }
  }

  Future<void> _fetchQuietly() async {
    try {
      final response = await _apiService.getData(AppConstants.supportMessagesUrl);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        // Only update if message counts differ to avoid redundant rebuilds
        if (data.length != messages.length) {
          messages.assignAll(data);
        }
      }
    } catch (_) {}
  }

  Future<bool> sendMessage(String text) async {
    if (text.trim().isEmpty) return false;
    try {
      isSending.value = true;
      final response = await _apiService.postData(AppConstants.supportSendUrl, {
        'message': text.trim(),
      });
      if (response.statusCode == 201) {
        await fetchMessages();
        return true;
      }
      return false;
    } catch (e) {
      print("Error sending message: $e");
      return false;
    } finally {
      isSending.value = false;
    }
  }

  void startPolling() {
    fetchMessages();
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchQuietly();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> launchWhatsApp() async {
    final whatsappUrl = Uri.parse("https://wa.me/91$supportPhoneNumber?text=Hello,%20I%20need%20help%20with%20my%20order.");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("WhatsApp Error", "Could not launch WhatsApp. Support Phone: +91 $supportPhoneNumber");
      }
    } catch (e) {
      Get.snackbar("Error", "Could not open WhatsApp: $e");
    }
  }

  Future<void> launchEmail() async {
    final emailUrl = Uri.parse("mailto:tech@bloomarina.com?subject=Support%20Request&body=Hello%20Bloomarina%20Team,");
    try {
      // Direct external application mode launch bypasses packages lookup restrictions
      await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar(
        "Email Info", 
        "Please email us at tech@bloomarina.com\n(Could not open email client automatically)",
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }
}
