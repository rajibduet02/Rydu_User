import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/network/auth_interceptor.dart';

void main() {
  test('authenticated API carries X-Device-ID and Authorization', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    RequestOptions? captured;
    dio.interceptors.add(
      AuthInterceptor(
        readAccessToken: () async => 'jwt-token',
        readDeviceId: () async => 'device-stable',
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: {}),
          );
        },
      ),
    );

    await dio.get<dynamic>('/api/v1/passenger/bookings/active');

    expect(captured, isNotNull);
    expect(captured!.headers['Authorization'], 'Bearer jwt-token');
    expect(captured!.headers['X-Device-ID'], 'device-stable');
  });
}
