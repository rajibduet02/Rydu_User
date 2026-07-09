import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<UserEntity> login({required String email, required String password});

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<bool> hasValidSession();

  Future<UserEntity?> getCurrentUser();

  Future<void> sendOtp({required String phone});

  Future<void> verifyOtp({required String phone, required String code});

  Future<String> requestPasswordReset({required String email});

  Future<void> signOut();

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
}
