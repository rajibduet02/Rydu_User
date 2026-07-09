import '../../domain/entities/wallet_data_entity.dart';
import 'wallet_payment_method_model.dart';
import 'wallet_transaction_model.dart';

class WalletDataModel extends WalletDataEntity {
  const WalletDataModel({
    required super.availableBalance,
    required super.thisMonthAmount,
    required super.promoCredits,
    required super.paymentMethods,
    required super.transactions,
  });

  factory WalletDataModel.fromSeed() {
    return WalletDataModel(
      availableBalance: 'BDT 250.00',
      thisMonthAmount: 'BDT 1,450',
      promoCredits: 'BDT 180',
      paymentMethods: const [
        WalletPaymentMethodModel(
          id: 'visa',
          name: 'Visa',
          last4: '6554',
          isDefault: true,
        ),
        WalletPaymentMethodModel(
          id: 'mc',
          name: 'Mastercard',
          last4: '8829',
          isDefault: false,
        ),
      ],
      transactions: const [
        WalletTransactionModel(
          id: '1',
          type: 'ride',
          amountSigned: -125.50,
          dateLabel: 'Today, 3:45 PM',
          description: 'Ride to Gulshan',
        ),
        WalletTransactionModel(
          id: '2',
          type: 'credit',
          amountSigned: 500.0,
          dateLabel: 'Yesterday, 10:20 AM',
          description: 'Wallet Top-up',
        ),
        WalletTransactionModel(
          id: '3',
          type: 'ride',
          amountSigned: -89.30,
          dateLabel: 'May 7, 2:15 PM',
          description: 'Ride to Dhanmondi',
        ),
        WalletTransactionModel(
          id: '4',
          type: 'promo',
          amountSigned: 100.0,
          dateLabel: 'May 6, 9:00 AM',
          description: 'Promo Credit',
        ),
        WalletTransactionModel(
          id: '5',
          type: 'ride',
          amountSigned: -156.20,
          dateLabel: 'May 5, 6:30 PM',
          description: 'Ride to Banani',
        ),
      ],
    );
  }

  WalletDataEntity toEntity() => this;
}
