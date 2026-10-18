import 'package:dio/dio.dart';

import '../../../../core/constants/passenger_api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../domain/service_area/service_area_models.dart';
import '../../domain/service_area/service_area_parser.dart';

abstract interface class ServiceAreaRemoteDatasource {
  Future<ServiceAreaConfig> fetch(ServiceAreaQuery query);
}

class ServiceAreaRemoteDatasourceImpl implements ServiceAreaRemoteDatasource {
  ServiceAreaRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ServiceAreaConfig> fetch(ServiceAreaQuery query) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.serviceArea,
        queryParameters: {
          'lat': query.latitude,
          'lng': query.longitude,
          if (query.placeId != null && query.placeId!.isNotEmpty)
            'placeId': query.placeId,
        },
      );
      final envelopeError = PassengerApiErrorMapper.fromEnvelope(response.data);
      if (envelopeError != null) throw envelopeError;
      final config = ServiceAreaParser.parseEnvelope(response.data);
      if (config == null) {
        throw const PassengerApiException('Invalid service area response.');
      }
      return config;
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }
}
