import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the device dialer for a driver phone from the booking payload.
Future<bool> dialDriverPhone(String phone) async {
  final trimmed = phone.trim();
  if (trimmed.isEmpty) return false;
  final uri = Uri(scheme: 'tel', path: trimmed);
  try {
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri);
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Driver call failed: $error');
    }
    return false;
  }
}
