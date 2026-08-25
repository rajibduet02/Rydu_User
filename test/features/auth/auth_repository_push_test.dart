import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/device/passenger_device_identity.dart';
import 'package:rydu_user/features/auth/data/datasources/auth0_datasource.dart';
import 'package:rydu_user/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:rydu_user/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rydu_user/features/auth/data/models/session_model.dart';
import 'package:rydu_user/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rydu_user/features/auth/domain/exceptions/auth_exception.dart';
import 'package:rydu_user/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuth0 implements Auth0Datasource {
  @override
  Future<void> clearCredentials() async {}

  @override
  Future<String> loginWithEmailPassword({
    required String email,
    required String password,
  }) async => 'auth0-access';
}

class _FakeRemote implements AuthRemoteDatasource {
  String? lastDeviceId;
  String? lastDeviceInfo;
  final List<String> calls = [];
  bool logoutThrows = false;

  @override
  Future<UserModel?> currentUser() async => null;

  @override
  Future<SessionModel> exchangeAuth0Token({
    required String auth0Token,
    String? deviceId,
    String? deviceInfo,
  }) async {
    lastDeviceId = deviceId;
    lastDeviceInfo = deviceInfo;
    return const SessionModel(
      accessToken: 'backend-jwt',
      sessionId: 'sess-1',
      user: UserModel(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'A',
        role: 'passenger',
      ),
    );
  }

  @override
  Future<void> logoutPassenger() async {
    calls.add('logout');
    if (logoutThrows) {
      throw const AuthException('logout failed');
    }
  }

  @override
  Future<void> registerPassenger({
    required String name,
    required String email,
    required String password,
  }) async {}

  @override
  Future<String> requestPasswordReset({required String email}) async => '';

  @override
  Future<void> sendOtp({required String phone}) async {}

  @override
  Future<void> verifyOtp({required String phone, required String code}) async {}
}

class _FakeLocal implements AuthLocalDatasource {
  final List<String> calls = [];
  SessionModel? session;

  @override
  Future<void> clearSession() async => calls.add('clear');

  @override
  Future<SessionModel?> getSession() async => session;

  @override
  Future<bool> hasValidSession() async => session != null;

  @override
  Future<void> registerWithPhone({
    required String fullName,
    required String fullPhone,
    required String password,
  }) async {}

  @override
  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {}

  @override
  Future<void> saveSession(SessionModel session) async {
    this.session = session;
    calls.add('save');
  }

  @override
  Future<void> sendPasswordResetOtp({required String fullPhone}) async {}

  @override
  Future<void> signInWithPhone({
    required String fullPhone,
    required String password,
  }) async {}

  @override
  Future<void> updateStoredDisplayName(String name) async {}

  @override
  Future<void> verifyOtpPlaceholder({
    required String phone,
    required String code,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('login sends stable deviceId', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final identity = PassengerDeviceIdentity(
      prefs,
      generateId: () => 'stable-device',
    );
    final remote = _FakeRemote();
    final repo = AuthRepositoryImpl(
      remote,
      _FakeLocal(),
      _FakeAuth0(),
      deviceIdentity: identity,
    );

    await repo.login(email: 'a@b.com', password: 'secret1');

    expect(remote.lastDeviceId, 'stable-device');
    expect(remote.lastDeviceInfo, isNotEmpty);
  });

  test('logout unregister called before session clear', () async {
    final remote = _FakeRemote();
    final local = _FakeLocal();
    final order = <String>[];
    final repo = AuthRepositoryImpl(
      remote,
      local,
      _FakeAuth0(),
      unregisterPushToken: () async => order.add('unregister'),
    );

    await repo.signOut();

    expect(order, ['unregister']);
    expect(remote.calls, ['logout']);
    expect(local.calls, ['clear']);
    expect([...order, ...remote.calls, ...local.calls], [
      'unregister',
      'logout',
      'clear',
    ]);
  });

  test('unregister failure does not block logout', () async {
    final remote = _FakeRemote();
    final local = _FakeLocal();
    final repo = AuthRepositoryImpl(
      remote,
      local,
      _FakeAuth0(),
      unregisterPushToken: () async {
        throw Exception('network');
      },
    );

    await repo.signOut();

    expect(remote.calls, ['logout']);
    expect(local.calls, ['clear']);
  });
}
