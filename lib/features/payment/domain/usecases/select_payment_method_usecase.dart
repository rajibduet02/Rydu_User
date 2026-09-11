import '../entities/payment_method_entity.dart';
import '../repositories/payment_repository.dart';

class SelectPaymentMethodUsecase {
  const SelectPaymentMethodUsecase(this._repository);

  final PaymentRepository _repository;

  Future<PaymentMethodEntity?> call(String methodLabel) async {
    final methods = await _repository.getPaymentMethods();
    for (final m in methods) {
      if (m.label == methodLabel || m.id == methodLabel) return m;
    }
    if (methodLabel == 'Card' || methodLabel.toLowerCase() == 'card') {
      return const PaymentMethodEntity(
        id: 'card',
        label: 'Card',
        isDefault: true,
      );
    }
    return null;
  }
}
