import '../repositories/payment_repository.dart';

class AddCardUsecase {
  const AddCardUsecase(this._repository);

  final PaymentRepository _repository;

  Future<void> call({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  }) {
    return _repository.addCard(
      cardNumber: cardNumber,
      expiry: expiry,
      cvv: cvv,
      cardholderName: cardholderName,
    );
  }
}
