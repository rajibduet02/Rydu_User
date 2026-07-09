import 'dart:io';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/models/user_model.dart';
import '../models/session_model.dart';
import '../utils/jwt_validator.dart';

abstract interface class AuthLocalDatasource {
  Future<void> saveSession(SessionModel session);

  Future<SessionModel?> getSession();

  Future<bool> hasValidSession();

  Future<void> clearSession();

  Future<void> signInWithPhone({
    required String fullPhone,
    required String password,
  });

  Future<void> registerWithPhone({
    required String fullName,
    required String fullPhone,
    required String password,
  });

  Future<void> sendPasswordResetOtp({required String fullPhone});

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> verifyOtpPlaceholder({
    required String phone,
    required String code,
  });
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  AuthLocalDatasourceImpl(this._secureStorage);

  final SecureStorageService _secureStorage;

  @override
  Future<void> saveSession(SessionModel session) async {
    await _secureStorage.write(
      AuthConstants.backendJwtKey,
      session.accessToken,
    );
    if (session.sessionId != null) {
      await _secureStorage.write(
        AuthConstants.sessionIdKey,
        session.sessionId!,
      );
    }
    final user = session.user;
    if (user != null) {
      await _secureStorage.write(AuthConstants.userIdKey, user.id);
      if (user.email != null) {
        await _secureStorage.write(AuthConstants.userEmailKey, user.email!);
      }
      if (user.displayName != null) {
        await _secureStorage.write(
          AuthConstants.userNameKey,
          user.displayName!,
        );
      }
    }
  }

  @override
  Future<SessionModel?> getSession() async {
    final token = await _secureStorage.read(AuthConstants.backendJwtKey);
    if (token == null || token.isEmpty) return null;

    final sessionId = await _secureStorage.read(AuthConstants.sessionIdKey);
    final userId = await _secureStorage.read(AuthConstants.userIdKey);
    final email = await _secureStorage.read(AuthConstants.userEmailKey);
    final name = await _secureStorage.read(AuthConstants.userNameKey);

    UserModel? user;
    if (userId != null && userId.isNotEmpty) {
      user = UserModel(id: userId, email: email, displayName: name);
    }

    return SessionModel(accessToken: token, sessionId: sessionId, user: user);
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await _secureStorage.read(AuthConstants.backendJwtKey);
    if (token == null || token.isEmpty) return false;
    return JwtValidator.isValid(token);
  }

  @override
  Future<void> clearSession() async {
    await _secureStorage.delete(AuthConstants.backendJwtKey);
    await _secureStorage.delete(AuthConstants.sessionIdKey);
    await _secureStorage.delete(AuthConstants.userIdKey);
    await _secureStorage.delete(AuthConstants.userEmailKey);
    await _secureStorage.delete(AuthConstants.userNameKey);
  }

  @override
  Future<void> signInWithPhone({
    required String fullPhone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
  }

  @override
  Future<void> registerWithPhone({
    required String fullName,
    required String fullPhone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
  }

  @override
  Future<void> sendPasswordResetOtp({required String fullPhone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  @override
  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
  }

  @override
  Future<void> verifyOtpPlaceholder({
    required String phone,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}

String buildDeviceInfo() => Platform.operatingSystem;
