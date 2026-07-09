import 'package:dio/dio.dart';

import '../constants/auth_constants.dart';
import '../storage/secure_storage_service.dart';

/// Attaches the stored backend JWT to outgoing API requests.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorageService _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(AuthConstants.backendJwtKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
