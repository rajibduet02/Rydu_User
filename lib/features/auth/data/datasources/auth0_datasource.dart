import 'package:auth0_flutter/auth0_flutter.dart';

import '../../../../core/constants/auth0_config.dart';
import '../utils/auth_debug_logger.dart';
import '../utils/auth_error_mapper.dart';

abstract interface class Auth0Datasource {
  Future<String> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> clearCredentials();
}

class Auth0DatasourceImpl implements Auth0Datasource {
  Auth0DatasourceImpl({Auth0? auth0})
    : _auth0 = auth0 ?? Auth0(Auth0Config.domain, Auth0Config.clientId);

  final Auth0 _auth0;

  @override
  Future<String> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    AuthDebugLogger.logSignInRequest(email: email.trim(), password: password);

    try {
      final credentials = await _auth0.api.login(
        usernameOrEmail: email.trim(),
        password: password,
        connectionOrRealm: Auth0Config.connection,
        audience: Auth0Config.audience,
      );

      await _auth0.credentialsManager.storeCredentials(credentials);
      AuthDebugLogger.logAuth0AccessToken(credentials.accessToken);
      return credentials.accessToken;
    } catch (e) {
      AuthDebugLogger.logAuth0LoginError(e);
      throw AuthErrorMapper.fromAuth0(e);
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      await _auth0.credentialsManager.clearCredentials();
    } catch (_) {
      // Best-effort cleanup during logout.
    }
  }
}
