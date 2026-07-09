import 'package:dio/dio.dart';

/// Thin wrapper around [Dio] for typed access and future interceptors.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Dio get dio => _dio;
}
