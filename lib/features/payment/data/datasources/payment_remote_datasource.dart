import '../models/payment_method_model.dart';

abstract interface class PaymentRemoteDatasource {
  Future<List<PaymentMethodModel>> fetchMethods();
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  PaymentRemoteDatasourceImpl();

  @override
  Future<List<PaymentMethodModel>> fetchMethods() async => const [];
}
