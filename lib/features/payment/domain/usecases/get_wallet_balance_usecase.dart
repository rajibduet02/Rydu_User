import '../repositories/payment_repository.dart';

class GetWalletBalanceUsecase {
  const GetWalletBalanceUsecase(this._repository);

  final PaymentRepository _repository;

  Future<double> call() => _repository.getWalletBalance();
}
