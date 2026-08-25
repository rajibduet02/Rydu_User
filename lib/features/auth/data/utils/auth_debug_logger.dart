import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/auth0_config.dart';
import '../../../../core/constants/auth_constants.dart';

/// Debug-only logging for auth API calls. Passwords and tokens are masked.
abstract final class AuthDebugLogger {
  static void logSignInRequest({
    required String email,
    required String password,
  }) {
    if (!kDebugMode) return;
    debugPrint('════════ AUTH SIGN-IN ════════');
    debugPrint('Step 1 — Auth0 login');
    debugPrint('  Domain: ${Auth0Config.domain}');
    debugPrint('  Client ID: ${Auth0Config.clientId}');
    debugPrint('  Audience: ${Auth0Config.audience}');
    debugPrint('  Connection: ${Auth0Config.connection}');
    debugPrint('  usernameOrEmail: $email');
    debugPrint('  password: *** (${password.length} chars)');
    debugPrint('Step 2 — Backend token exchange');
    debugPrint('  POST ${ApiConstants.baseUrl}${AuthConstants.loginPath}');
    debugPrint(
      '  Body: {auth0Token: <accessToken from Auth0>, deviceId: <stable uuid>, deviceInfo: <platform>}',
    );
    debugPrint('═══════════════════════════════');
  }

  static void logAuth0AccessToken(String accessToken) {
    if (!kDebugMode) return;
    final preview = _maskToken(accessToken);
    debugPrint(
      'Auth0 accessToken received: $preview (${accessToken.length} chars)',
    );
    debugPrint('  (using accessToken — NOT idToken)');
  }

  static void logTokenExchangeRequest({
    required String accessToken,
    required String deviceInfo,
    String? deviceId,
  }) {
    if (!kDebugMode) return;
    debugPrint('── SIGN-IN token exchange request ──');
    debugPrint('  auth0Token: ${_maskToken(accessToken)}');
    debugPrint(
      '  deviceId: ${deviceId == null || deviceId.isEmpty ? '(none)' : deviceId}',
    );
    debugPrint('  deviceInfo: $deviceInfo');
  }

  static void logTokenExchangeResponse({
    required int? statusCode,
    required dynamic data,
    Object? error,
  }) {
    if (!kDebugMode) return;
    debugPrint('── SIGN-IN token exchange response ──');
    if (error != null) {
      debugPrint('  Error: $error');
    } else {
      debugPrint('  Status: $statusCode');
      debugPrint('  Data: $data');
    }
    debugPrint('═══════════════════════════════');
  }

  static void logAuth0LoginError(Object error) {
    if (!kDebugMode) return;
    debugPrint('Auth0 login error: $error');
    debugPrint('  (backend /login was NOT called — fix Auth0 config first)');
  }

  static String _maskToken(String token) {
    if (token.length <= 12) return '***';
    return '${token.substring(0, 8)}...${token.substring(token.length - 4)}';
  }
}
