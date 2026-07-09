import '../../domain/entities/wallet_transaction_entity.dart';

class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    required super.id,
    required super.type,
    required super.amountSigned,
    required super.dateLabel,
    required super.description,
  });

  WalletTransactionEntity toEntity() => this;

  bool get isCredit => amountSigned > 0;
}
