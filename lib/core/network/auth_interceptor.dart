import 'package:dio/dio.dart';

import '../constants/auth_constants.dart';
import '../device/passenger_device_identity.dart';
import '../storage/secure_storage_service.dart';

/// Attaches the stored backend JWT and stable Passenger device id.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    SecureStorageService? secureStorage,
    PassengerDeviceIdentity? deviceIdentity,
    Future<String?> Function()? readAccessToken,
    Future<String?> Function()? readDeviceId,
  }) : _deviceIdentity = deviceIdentity,
       _readAccessToken =
           readAccessToken ??
           (() async {
             if (secureStorage == null) return null;
             return secureStorage.read(AuthConstants.backendJwtKey);
           }),
       _readDeviceId = readDeviceId;

  final PassengerDeviceIdentity? _deviceIdentity;
  final Future<String?> Function() _readAccessToken;
  final Future<String?> Function()? _readDeviceId;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}

    try {
      final deviceId =
          await (_readDeviceId?.call() ?? _deviceIdentity?.getOrCreate());
      if (deviceId != null && deviceId.isNotEmpty) {
        options.headers['X-Device-ID'] = deviceId;
      }
    } catch (_) {}

    handler.next(options);
  }
}
