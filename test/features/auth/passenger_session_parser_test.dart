import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/auth/data/utils/passenger_session_parser.dart';
import 'package:rydu_user/features/auth/domain/exceptions/auth_exception.dart';

void main() {
  group('PassengerSessionParser', () {
    test('parses nested data envelope', () {
      final session = PassengerSessionParser.parse({
        'success': true,
        'data': {
          'token': 'backend-jwt',
          'sessionId': 'sess-1',
          'user': {
            'id': 'user-1',
            'email': 'test@example.com',
            'name': 'Test User',
          },
        },
      });

      expect(session.accessToken, 'backend-jwt');
      expect(session.sessionId, 'sess-1');
      expect(session.user?.id, 'user-1');
      expect(session.user?.email, 'test@example.com');
    });

    test('throws when token missing', () {
      expect(
        () => PassengerSessionParser.parse({'success': true, 'data': {}}),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
