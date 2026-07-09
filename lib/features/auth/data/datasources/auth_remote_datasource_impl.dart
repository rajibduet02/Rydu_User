import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../shared/models/user_model.dart';
import '../models/session_model.dart';
import '../utils/auth_debug_logger.dart';
import '../utils/auth_error_mapper.dart';
import '../utils/passenger_session_parser.dart';
import '../../domain/exceptions/auth_exception.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> registerPassenger({
    required String name,
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      debugPrint('════════ AUTH SIGN-UP ════════');
      debugPrint('POST ${ApiConstants.baseUrl}${AuthConstants.registerPath}');
      debugPrint(
        'Body: {name: $name, email: $email, password: *** (${password.length} chars)}',
      );
    }

    try {
      final response = await _apiClient.dio.post<dynamic>(
        AuthConstants.registerPath,
        data: {'name': name, 'email': email, 'password': password},
      );

      if (kDebugMode) {
        debugPrint('── SIGN-UP register response ──');
        debugPrint('  Status: ${response.statusCode}');
        debugPrint('  Data: ${response.data}');
        debugPrint('═══════════════════════════════');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('── SIGN-UP register response ──');
        debugPrint('  Error: ${e.message}');
        debugPrint('═══════════════════════════════');
      }
      throw AuthErrorMapper.fromDio(e);
    }
  }

  @override
  Future<SessionModel> exchangeAuth0Token({
    required String auth0Token,
    String? deviceId,
    String? deviceInfo,
  }) async {
    AuthDebugLogger.logTokenExchangeRequest(
      accessToken: auth0Token,
      deviceInfo: deviceInfo ?? '',
    );

    try {
      final response = await _apiClient.dio.post<dynamic>(
        AuthConstants.loginPath,
        data: {
          'auth0Token': auth0Token,
          if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
          if (deviceInfo != null && deviceInfo.isNotEmpty)
            'deviceInfo': deviceInfo,
        },
      );
      AuthDebugLogger.logTokenExchangeResponse(
        statusCode: response.statusCode,
        data: response.data,
      );
      return PassengerSessionParser.parse(response.data);
    } on DioException catch (e) {
      AuthDebugLogger.logTokenExchangeResponse(
        statusCode: e.response?.statusCode,
        data: e.response?.data,
        error: e.message,
      );
      throw AuthErrorMapper.fromDio(e);
    }
  }

  @override
  Future<void> logoutPassenger({String? sessionId}) async {
    try {
      await _apiClient.dio.post<void>(
        AuthConstants.logoutPath,
        data: {
          if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
        },
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404 || statusCode == 501) return;
      throw AuthErrorMapper.fromDio(e);
    }
  }

  @override
  Future<String> requestPasswordReset({required String email}) async {
    final trimmedEmail = email.trim();

    if (kDebugMode) {
      debugPrint('════════ AUTH FORGOT PASSWORD ════════');
      debugPrint(
        'POST ${ApiConstants.baseUrl}${AuthConstants.forgotPasswordPath}',
      );
      debugPrint('Body: {email: $trimmedEmail}');
    }

    try {
      final response = await _apiClient.dio.post<dynamic>(
        AuthConstants.forgotPasswordPath,
        data: {'email': trimmedEmail},
      );

      if (kDebugMode) {
        debugPrint('── FORGOT PASSWORD response ──');
        debugPrint('  Status: ${response.statusCode}');
        debugPrint('  Data: ${response.data}');
        debugPrint('═══════════════════════════════');
      }

      final raw = response.data;
      if (raw is! Map) {
        throw const AuthException('Invalid server response.');
      }

      final root = Map<String, dynamic>.from(raw);
      if (root['success'] == false) {
        final error = root['error'];
        if (error is Map) {
          final message = error['message'];
          if (message is String && message.trim().isNotEmpty) {
            throw AuthException(message.trim());
          }
        }
        throw const AuthException('Something went wrong. Please try again.');
      }

      final payload = ApiResponseParser.unwrapData(root);
      final message = payload['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }

      return 'Password reset instructions sent if account exists';
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('── FORGOT PASSWORD response ──');
        debugPrint('  Error: ${e.message}');
        debugPrint('  Status: ${e.response?.statusCode}');
        debugPrint('  Data: ${e.response?.data}');
        debugPrint('═══════════════════════════════');
      }
      throw AuthErrorMapper.fromDio(e);
    } on FormatException {
      throw const AuthException('Invalid server response.');
    }
  }

  @override
  Future<void> sendOtp({required String phone}) async {}

  @override
  Future<void> verifyOtp({required String phone, required String code}) async {}

  @override
  Future<UserModel?> currentUser() async => null;
}
