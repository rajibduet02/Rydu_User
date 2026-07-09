import '../../../../shared/models/user_model.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../models/session_model.dart';

abstract final class PassengerSessionParser {
  static SessionModel parse(dynamic data) {
    if (data is! Map) {
      throw const AuthException('Invalid server response.');
    }

    final root = Map<String, dynamic>.from(data);
    final payload = ApiResponseParser.unwrapData(root);

    final token = _readToken(payload);
    if (token == null || token.isEmpty) {
      throw const AuthException('Token exchange failed. Please try again.');
    }

    final sessionId = payload['sessionId']?.toString();
    final user = _parseUser(payload['user']);

    return SessionModel(accessToken: token, sessionId: sessionId, user: user);
  }

  static String? _readToken(Map<String, dynamic> payload) {
    for (final key in [
      'token',
      'accessToken',
      'jwt',
      'backendJwt',
      'backendToken',
    ]) {
      final value = payload[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static UserModel? _parseUser(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = map['id']?.toString() ?? map['userId']?.toString();
    if (id == null || id.isEmpty) return null;

    return UserModel(
      id: id,
      email: map['email']?.toString(),
      displayName: map['name']?.toString() ?? map['displayName']?.toString(),
    );
  }
}
