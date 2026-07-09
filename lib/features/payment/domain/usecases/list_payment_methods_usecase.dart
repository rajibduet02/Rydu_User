import '../entities/payment_method_entity.dart';
import '../repositories/payment_repository.dart';

class ListPaymentMethodsUsecase {
  const ListPaymentMethodsUsecase(this._repository);

  final PaymentRepository _repository;

  Future<List<PaymentMethodEntity>> call() => _repository.getPaymentMethods();
}
