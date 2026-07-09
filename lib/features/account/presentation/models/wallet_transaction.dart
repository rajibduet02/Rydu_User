import '../../domain/entities/wallet_transaction_entity.dart';

export '../../domain/entities/wallet_transaction_entity.dart';

typedef WalletTransaction = WalletTransactionEntity;

extension WalletTransactionPresentation on WalletTransactionEntity {
  bool get isCredit => amountSigned > 0;
}
