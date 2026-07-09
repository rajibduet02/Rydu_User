import 'wallet_payment_method_entity.dart';
import 'wallet_transaction_entity.dart';

class WalletDataEntity {
  const WalletDataEntity({
    required this.availableBalance,
    required this.thisMonthAmount,
    required this.promoCredits,
    required this.paymentMethods,
    required this.transactions,
  });

  final String availableBalance;
  final String thisMonthAmount;
  final String promoCredits;
  final List<WalletPaymentMethodEntity> paymentMethods;
  final List<WalletTransactionEntity> transactions;
}
