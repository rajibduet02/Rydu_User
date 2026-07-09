import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only HTTP logging. Never logs Authorization headers or request bodies
/// that may contain passwords or tokens.
class ErrorInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✕ ${err.requestOptions.method} ${err.requestOptions.uri} '
        '${err.response?.statusCode ?? err.type}',
      );
    }
    handler.next(err);
  }
}
