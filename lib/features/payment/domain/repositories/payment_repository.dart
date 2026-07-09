import '../entities/payment_method_entity.dart';

abstract interface class PaymentRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods();

  Future<double> getWalletBalance();

  Future<void> addCard({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  });

  Future<void> addVoucher(String code);
}
