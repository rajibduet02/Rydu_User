import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../../../core/constants/passenger_api_paths.dart';
import '../models/payment_method_model.dart';
import 'package:dio/dio.dart';

abstract interface class PaymentRemoteDatasource {
  Future<List<PaymentMethodModel>> fetchMethods();
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  PaymentRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PaymentMethodModel>> fetchMethods() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.paymentMethods,
      );
      final failed = PassengerApiErrorMapper.fromEnvelope(response.data);
      if (failed != null) throw failed;
      final listRaw = ApiResponseParser.unwrapList(response.data);
      final methods = <PaymentMethodModel>[];
      for (final item in listRaw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final code = map['code']?.toString().trim();
        if (code == null || code.isEmpty) continue;
        methods.add(
          PaymentMethodModel(
            id: code,
            label: map['name']?.toString() ?? map['label']?.toString() ?? code,
            isDefault: map['isDefault'] == true || map['default'] == true,
          ),
        );
      }
      return methods;
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }
}
