class WalletPaymentMethodEntity {
  const WalletPaymentMethodEntity({
    required this.id,
    required this.name,
    required this.last4,
    required this.isDefault,
  });

  final String id;
  final String name;
  final String last4;
  final bool isDefault;
}
