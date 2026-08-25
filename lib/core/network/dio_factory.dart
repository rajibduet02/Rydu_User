import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../device/passenger_device_identity.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Creates a configured [Dio] instance for the app.
Dio createDio(
  SecureStorageService secureStorage, {
  PassengerDeviceIdentity? deviceIdentity,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.interceptors.add(ErrorInterceptor());
  dio.interceptors.add(
    AuthInterceptor(
      secureStorage: secureStorage,
      deviceIdentity: deviceIdentity,
    ),
  );
  return dio;
}
