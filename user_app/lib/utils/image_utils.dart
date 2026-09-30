import 'app_constants.dart';

class ImageUtils {
  static const String fallbackImage =
      'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400';

  static String formatImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return fallbackImage;
    }

    String trimmed = url.trim();

    // Handle relative uploads paths
    if (trimmed.startsWith('/uploads/') || trimmed.startsWith('uploads/')) {
      String cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '${AppConstants.baseUrl}$cleanPath';
    }

    // Handle localhost / 127.0.0.1 / 10.0.2.2 URLs stored in DB when active server is Live
    if (AppConstants.useLiveServer &&
        (trimmed.contains('localhost:5001') ||
         trimmed.contains('127.0.0.1:5001') ||
         trimmed.contains('10.0.2.2:5001'))) {
      trimmed = trimmed
          .replaceAll('http://localhost:5001', AppConstants.liveServerUrl)
          .replaceAll('http://127.0.0.1:5001', AppConstants.liveServerUrl)
          .replaceAll('http://10.0.2.2:5001', AppConstants.liveServerUrl);
    }

    return trimmed;
  }
}
