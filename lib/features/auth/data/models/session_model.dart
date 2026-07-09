import '../../../../shared/models/user_model.dart';

class SessionModel {
  const SessionModel({
    required this.accessToken,
    this.refreshToken,
    this.sessionId,
    this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final String? sessionId;
  final UserModel? user;
}
