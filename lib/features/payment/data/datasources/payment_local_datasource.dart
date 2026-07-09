import '../models/payment_method_model.dart';

abstract interface class PaymentLocalDatasource {
  Future<List<PaymentMethodModel>> fetchMethods();

  Future<double> fetchRyduCashBalance();

  Future<void> simulateAddCardDelay();

  Future<void> simulateAddVoucherDelay();
}

class PaymentLocalDatasourceImpl implements PaymentLocalDatasource {
  static const _methods = <PaymentMethodModel>[
    PaymentMethodModel(id: 'cash', label: 'Cash', isDefault: true),
    PaymentMethodModel(
      id: 'card_visa',
      label: 'Visa •••• 6554',
      isDefault: false,
    ),
    PaymentMethodModel(
      id: 'card_mc',
      label: 'Mastercard •••• 8829',
      isDefault: false,
    ),
    PaymentMethodModel(
      id: 'rydu_balance',
      label: 'RYD U balance',
      isDefault: false,
    ),
  ];

  @override
  Future<List<PaymentMethodModel>> fetchMethods() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _methods;
  }

  @override
  Future<double> fetchRyduCashBalance() async => 0;

  @override
  Future<void> simulateAddCardDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 750));
  }

  @override
  Future<void> simulateAddVoucherDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
