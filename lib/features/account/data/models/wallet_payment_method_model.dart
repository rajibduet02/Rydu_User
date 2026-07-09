import '../../domain/entities/wallet_payment_method_entity.dart';

class WalletPaymentMethodModel extends WalletPaymentMethodEntity {
  const WalletPaymentMethodModel({
    required super.id,
    required super.name,
    required super.last4,
    required super.isDefault,
  });

  WalletPaymentMethodEntity toEntity() => this;
}
