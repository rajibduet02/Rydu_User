import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../models/wallet_payment_method.dart';
import '../models/wallet_transaction.dart';
import 'account_dependencies.dart';

class WalletState {
  const WalletState({
    this.availableBalance = '',
    this.thisMonthAmount = '',
    this.promoCredits = '',
    this.paymentMethods = const [],
    this.transactions = const [],
    this.selectedPaymentMethod,
    this.isLoading = false,
    this.errorMessage,
  });

  final String availableBalance;
  final String thisMonthAmount;
  final String promoCredits;
  final List<WalletPaymentMethod> paymentMethods;
  final List<WalletTransaction> transactions;
  final String? selectedPaymentMethod;
  final bool isLoading;
  final String? errorMessage;

  WalletState copyWith({
    String? availableBalance,
    String? thisMonthAmount,
    String? promoCredits,
    List<WalletPaymentMethod>? paymentMethods,
    List<WalletTransaction>? transactions,
    String? selectedPaymentMethod,
    bool clearSelectedPaymentMethod = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      availableBalance: availableBalance ?? this.availableBalance,
      thisMonthAmount: thisMonthAmount ?? this.thisMonthAmount,
      promoCredits: promoCredits ?? this.promoCredits,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      transactions: transactions ?? this.transactions,
      selectedPaymentMethod: clearSelectedPaymentMethod
          ? null
          : (selectedPaymentMethod ?? this.selectedPaymentMethod),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class WalletController extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  void _push(String location) {
    ref.read(goRouterProvider).push(location);
  }

  Future<void> loadWalletData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(getWalletDataUsecaseProvider).call();
      state = state.copyWith(
        availableBalance: data.availableBalance,
        thisMonthAmount: data.thisMonthAmount,
        promoCredits: data.promoCredits,
        paymentMethods: data.paymentMethods,
        transactions: data.transactions,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load wallet.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void addMoney() {
    _push(RouteNames.addMoney);
  }

  void sendMoney() {
    _push(RouteNames.sendMoney);
  }

  void addPaymentMethod() {
    _push(RouteNames.addPaymentMethod);
  }

  void selectPaymentMethod(String id) {
    state = state.copyWith(selectedPaymentMethod: id, clearError: true);
  }

  void openTransaction(String id) {
    final uri = Uri(
      path: RouteNames.transactionDetails,
      queryParameters: {'id': id},
    );
    _push(uri.toString());
  }

  void openAllTransactions() {
    _push(RouteNames.walletTransactions);
  }
}
