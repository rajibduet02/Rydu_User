class WalletTransactionEntity {
  const WalletTransactionEntity({
    required this.id,
    required this.type,
    required this.amountSigned,
    required this.dateLabel,
    required this.description,
  });

  final String id;
  final String type;
  final double amountSigned;
  final String dateLabel;
  final String description;
}
