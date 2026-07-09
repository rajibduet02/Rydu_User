import '../../../../shared/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth0_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local, this._auth0);

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;
  final Auth0Datasource _auth0;

  UserEntity _mapUser(UserModel user) {
    return UserEntity(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
    );
  }

  UserEntity _requireUser(UserModel? user) {
    if (user == null) {
      throw const AuthException(
        'Could not load your profile. Please try again.',
      );
    }
    return _mapUser(user);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final auth0Token = await _auth0.loginWithEmailPassword(
      email: email,
      password: password,
    );

    final session = await _remote.exchangeAuth0Token(
      auth0Token: auth0Token,
      deviceInfo: buildDeviceInfo(),
    );
    await _local.saveSession(session);
    return _requireUser(session.user);
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _remote.registerPassenger(
      name: displayName.trim(),
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<bool> hasValidSession() => _local.hasValidSession();

  @override
  Future<UserEntity?> getCurrentUser() async {
    final session = await _local.getSession();
    final user = session?.user;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  Future<void> sendOtp({required String phone}) =>
      _remote.sendOtp(phone: phone);

  @override
  Future<void> verifyOtp({required String phone, required String code}) =>
      _remote.verifyOtp(phone: phone, code: code);

  @override
  Future<String> requestPasswordReset({required String email}) =>
      _remote.requestPasswordReset(email: email.trim());

  @override
  Future<void> signOut() async {
    final session = await _local.getSession();
    try {
      await _remote.logoutPassenger(sessionId: session?.sessionId);
    } catch (_) {
      // Continue local cleanup even if remote logout fails.
    }
    await _local.clearSession();
    await _auth0.clearCredentials();
  }

  @override
  Future<void> signInWithPhone({
    required String fullPhone,
    required String password,
  }) => _local.signInWithPhone(fullPhone: fullPhone, password: password);

  @override
  Future<void> registerWithPhone({
    required String fullName,
    required String fullPhone,
    required String password,
  }) => _local.registerWithPhone(
    fullName: fullName,
    fullPhone: fullPhone,
    password: password,
  );

  @override
  Future<void> sendPasswordResetOtp({required String fullPhone}) =>
      _local.sendPasswordResetOtp(fullPhone: fullPhone);

  @override
  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) => _local.resetPassword(
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );
}
