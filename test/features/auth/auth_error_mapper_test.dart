import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/auth/data/utils/auth_error_mapper.dart';
import 'package:rydu_user/features/auth/domain/exceptions/auth_exception.dart';

void main() {
  group('AuthErrorMapper.fromDio', () {
    test('parses nested error.message from backend envelope', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/register'),
        response: Response(
          requestOptions: RequestOptions(path: '/register'),
          statusCode: 400,
          data: {
            'success': false,
            'error': {
              'code': 'REGISTRATION_FAILED',
              'message': 'Auth0: PasswordStrengthError: Password is too weak',
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = AuthErrorMapper.fromDio(error);
      expect(mapped, isA<AuthException>());
      expect(mapped.message, contains('Password is too weak'));
    });

    test('maps ACCOUNT_DEACTIVATED 403', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 403,
          data: {
            'success': false,
            'error': {
              'code': 'ACCOUNT_DEACTIVATED',
              'message': 'Account deactivated',
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );
      final mapped = AuthErrorMapper.fromDio(error);
      expect(mapped.code, 'ACCOUNT_DEACTIVATED');
      expect(mapped.message, contains('deactivated'));
    });

    test('does not treat VALIDATION_ERROR as ACCOUNT_DEACTIVATED', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 400,
          data: {
            'success': false,
            'error': {'code': 'VALIDATION_ERROR', 'message': 'Invalid email'},
          },
        ),
        type: DioExceptionType.badResponse,
      );
      final mapped = AuthErrorMapper.fromDio(error);
      expect(mapped.code, 'VALIDATION_ERROR');
      expect(mapped.code, isNot('ACCOUNT_DEACTIVATED'));
    });
  });
}
