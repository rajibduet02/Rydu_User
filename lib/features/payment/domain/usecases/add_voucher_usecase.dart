import '../repositories/payment_repository.dart';

class AddVoucherUsecase {
  const AddVoucherUsecase(this._repository);

  final PaymentRepository _repository;

  Future<void> call(String code) => _repository.addVoucher(code);
}
