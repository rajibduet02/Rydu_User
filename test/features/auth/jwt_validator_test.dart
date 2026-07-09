import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/auth/data/utils/jwt_validator.dart';

void main() {
  group('JwtValidator', () {
    test('returns false for empty token', () {
      expect(JwtValidator.isValid(''), isFalse);
    });

    test('returns true for non-jwt opaque token', () {
      expect(JwtValidator.isValid('opaque-session-token'), isTrue);
    });

    test('returns false for expired jwt payload', () {
      // exp = 1000000000 (Sep 2001)
      const expired = 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjEwMDAwMDAwMDB9.signature';
      expect(JwtValidator.isValid(expired), isFalse);
    });
  });
}
