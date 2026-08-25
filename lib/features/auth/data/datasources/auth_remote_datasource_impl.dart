import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/models/user_model.dart';
import '../models/session_model.dart';
import '../utils/auth_debug_logger.dart';
import '../utils/auth_error_mapper.dart';
import '../utils/passenger_session_parser.dart';
import '../../domain/exceptions/auth_exception.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl(this._apiClient, this._secureStorage);

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

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
      deviceId: deviceId,
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
  Future<void> logoutPassenger() async {
    final tokenLabel = await _backendSessionTokenLabel();

    if (kDebugMode) {
      debugPrint('════════ AUTH LOGOUT ════════');
      debugPrint('POST ${ApiConstants.baseUrl}${AuthConstants.logoutPath}');
      debugPrint('Backend session token: $tokenLabel');
    }

    try {
      final response = await _apiClient.dio.post<dynamic>(
        AuthConstants.logoutPath,
      );

      if (kDebugMode) {
        debugPrint('← Status: ${response.statusCode}');
        debugPrint('Response: ${response.data}');
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
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('← Status: ${e.response?.statusCode}');
        debugPrint('Response: ${e.response?.data}');
      }
      throw AuthErrorMapper.fromDio(e);
    } on FormatException {
      throw const AuthException('Invalid server response.');
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
  Future<UserModel?> currentUser() async {
    final tokenLabel = await _tokenPresenceLabel();

    if (kDebugMode) {
      debugPrint('════════ AUTH GET ME ════════');
      debugPrint('GET ${ApiConstants.baseUrl}${AuthConstants.mePath}');
      debugPrint('Authorization: Bearer $tokenLabel');
    }

    try {
      final response = await _apiClient.dio.get<dynamic>(AuthConstants.mePath);

      if (kDebugMode) {
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Response: ${response.data}');
        debugPrint('════════════════════════════');
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

      return PassengerSessionParser.parseUser(
        ApiResponseParser.unwrapData(root),
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('Status: ${e.response?.statusCode}');
        debugPrint('Response: ${e.response?.data}');
        debugPrint('════════════════════════════');
      }
      throw AuthErrorMapper.fromDio(e);
    } on FormatException {
      throw const AuthException('Invalid server response.');
    }
  }

  Future<String> _backendSessionTokenLabel() async {
    final token = await _secureStorage.read(AuthConstants.backendJwtKey);
    return token != null && token.isNotEmpty ? 'PRESENT' : 'MISSING';
  }

  Future<String> _tokenPresenceLabel() async {
    final token = await _secureStorage.read(AuthConstants.backendJwtKey);
    return token != null && token.isNotEmpty
        ? '[TOKEN PRESENT - DO NOT PRINT FULL TOKEN]'
        : '[NO TOKEN]';
  }
}
