import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/passenger_api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/passenger_api_error_mapper.dart';

abstract interface class PassengerPushRemoteDatasource {
  Future<void> registerToken({required String token, required String deviceId});

  Future<void> unregisterToken();
}

class PassengerPushRemoteDatasourceImpl
    implements PassengerPushRemoteDatasource {
  PassengerPushRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> registerToken({
    required String token,
    required String deviceId,
  }) async {
    try {
      final response = await _apiClient.dio.put<dynamic>(
        PassengerApiPaths.pushToken,
        data: {'token': token, 'deviceId': deviceId},
      );
      final error = PassengerApiErrorMapper.fromEnvelope(response.data);
      if (error != null) throw error;
      if (kDebugMode) {
        debugPrint(
          'PassengerPush: register ok deviceId=$deviceId status=${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<void> unregisterToken() async {
    try {
      final response = await _apiClient.dio.delete<dynamic>(
        PassengerApiPaths.pushToken,
      );
      final error = PassengerApiErrorMapper.fromEnvelope(response.data);
      if (error != null) throw error;
      if (kDebugMode) {
        debugPrint(
          'PassengerPush: unregister ok status=${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }
}
