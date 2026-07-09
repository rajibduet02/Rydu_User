import '../entities/payment_method_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentMethodsUsecase {
  const GetPaymentMethodsUsecase(this._repository);

  final PaymentRepository _repository;

  Future<List<PaymentMethodEntity>> call() => _repository.getPaymentMethods();
}
