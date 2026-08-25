import 'package:dio/dio.dart';

import '../../../../core/constants/passenger_api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../domain/entities/passenger_profile.dart';
import '../utils/passenger_profile_parser.dart';
import '../utils/passenger_profile_requests.dart';
import 'passenger_profile_remote_datasource.dart';

class PassengerProfileRemoteDatasourceImpl
    implements PassengerProfileRemoteDatasource {
  PassengerProfileRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PassengerProfile> fetchProfile() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.profile,
      );
      _throwIfFailed(response.data);
      return PassengerProfileParser.parse(response.data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<PassengerProfile> patchProfile(Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.dio.patch<dynamic>(
        PassengerApiPaths.profile,
        data: body,
      );
      _throwIfFailed(response.data);
      return PassengerProfileParser.parse(response.data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<PassengerProfile> uploadAvatar(FormData formData) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(
        PassengerApiPaths.profileAvatar,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      _throwIfFailed(response.data);
      return PassengerProfileParser.parse(response.data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<PassengerProfile> deleteAvatar() async {
    try {
      final response = await _apiClient.dio.delete<dynamic>(
        PassengerApiPaths.profileAvatar,
      );
      _throwIfFailed(response.data);
      if (response.data == null) {
        throw const PassengerApiException('Invalid server response.');
      }
      try {
        return PassengerProfileParser.parse(response.data);
      } on FormatException {
        final current = await fetchProfile();
        return current.copyWith(clearAvatar: true);
      }
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<void> deactivate({required bool confirm}) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(
        PassengerApiPaths.profileDeactivate,
        data: PassengerProfileRequests.deactivate(confirm: confirm),
      );
      _throwIfFailed(response.data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  void _throwIfFailed(dynamic raw) {
    final error = PassengerApiErrorMapper.fromEnvelope(raw);
    if (error != null) throw error;
  }
}
