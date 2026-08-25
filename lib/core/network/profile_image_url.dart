import '../constants/api_constants.dart';

/// Resolves a passenger avatar URL against the backend origin.
///
/// Relative paths such as `/uploads/avatars/passengers/x.jpg` are joined to
/// the API host origin (scheme + host + port), never to `/api/v1`.
String? resolveProfileImageUrl(String? raw, {String? baseUrl}) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;

  final lower = value.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return value;
  }

  final origin = _originOf(baseUrl ?? ApiConstants.baseUrl);
  if (origin.isEmpty) return value;

  if (value.startsWith('/')) return '$origin$value';
  return '$origin/$value';
}

String _originOf(String baseUrl) {
  final parsed = Uri.tryParse(baseUrl.trim());
  if (parsed == null || parsed.host.isEmpty) return '';
  return Uri(
    scheme: parsed.scheme.isEmpty ? 'http' : parsed.scheme,
    host: parsed.host,
    port: parsed.hasPort ? parsed.port : null,
  ).origin;
}
