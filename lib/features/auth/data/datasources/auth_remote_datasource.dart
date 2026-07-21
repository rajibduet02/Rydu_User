import '../../../../shared/models/user_model.dart';
import '../models/session_model.dart';

abstract interface class AuthRemoteDatasource {
  Future<void> registerPassenger({
    required String name,
    required String email,
    required String password,
  });

  Future<SessionModel> exchangeAuth0Token({
    required String auth0Token,
    String? deviceId,
    String? deviceInfo,
  });

  Future<void> logoutPassenger();

  Future<String> requestPasswordReset({required String email});

  Future<void> sendOtp({required String phone});

  Future<void> verifyOtp({required String phone, required String code});

  Future<UserModel?> currentUser();
}
