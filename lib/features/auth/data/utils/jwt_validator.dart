import 'dart:convert';

/// Lightweight JWT expiry check for auto-login (no signature verification).
abstract final class JwtValidator {
  static bool isValid(String token) {
    if (token.trim().isEmpty) return false;

    final parts = token.split('.');
    if (parts.length != 3) return true;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = json.decode(utf8.decode(base64Url.decode(normalized)));
      if (payload is! Map) return true;

      final exp = payload['exp'];
      if (exp is int) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return expiry.isAfter(DateTime.now());
      }
      return true;
    } catch (_) {
      return true;
    }
  }
}
