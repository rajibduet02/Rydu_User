/// App-wide API / socket environment configuration.
///
/// Prefer `--dart-define` over hardcoding. Production must use HTTPS.
abstract final class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://103.208.181.253:3000',
  );

  /// Full passenger API prefix including `/api/v1/passenger`.
  static const passengerApiBaseUrl = String.fromEnvironment(
    'PASSENGER_API_BASE_URL',
    defaultValue: 'http://103.208.181.253:3000/api/v1/passenger',
  );

  static const socketUrl = String.fromEnvironment(
    'PASSENGER_SOCKET_URL',
    defaultValue: 'http://103.208.181.253:3000',
  );

  /// Relative path prefix used with [baseUrl] Dio client.
  static String get passengerPathPrefix {
    final full = passengerApiBaseUrl.trim();
    final base = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (full.startsWith(base)) {
      final rest = full.substring(base.length);
      return rest.isEmpty ? '/api/v1/passenger' : rest;
    }
    return '/api/v1/passenger';
  }

  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
  static const sendTimeout = Duration(seconds: 30);
}
