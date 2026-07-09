class PaymentMethodEntity {
  const PaymentMethodEntity({
    required this.id,
    required this.label,
    required this.isDefault,
  });

  final String id;
  final String label;
  final bool isDefault;
}
