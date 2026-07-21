import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'payment_dependencies.dart';

abstract final class PaymentAccountTypes {
  static const personal = 'personal';
  static const business = 'business';
}

class PaymentMethodState {
  const PaymentMethodState({
    this.selectedPaymentMethod = '',
    this.selectedAccountType = PaymentAccountTypes.personal,
    this.isRyduBalanceEnabled = false,
    this.ryduCashBalance = 0,
    this.selectedVoucherCode,
    this.errorMessage,
  });

  final String selectedPaymentMethod;
  final String selectedAccountType;
  final bool isRyduBalanceEnabled;
  final double ryduCashBalance;
  final String? selectedVoucherCode;
  final String? errorMessage;

  PaymentMethodState copyWith({
    String? selectedPaymentMethod,
    String? selectedAccountType,
    bool? isRyduBalanceEnabled,
    double? ryduCashBalance,
    String? selectedVoucherCode,
    bool clearVoucherCode = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentMethodState(
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedAccountType: selectedAccountType ?? this.selectedAccountType,
      isRyduBalanceEnabled: isRyduBalanceEnabled ?? this.isRyduBalanceEnabled,
      ryduCashBalance: ryduCashBalance ?? this.ryduCashBalance,
      selectedVoucherCode: clearVoucherCode
          ? null
          : (selectedVoucherCode ?? this.selectedVoucherCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PaymentMethodController extends Notifier<PaymentMethodState> {
  @override
  PaymentMethodState build() {
    Future.microtask(loadPaymentData);
    return const PaymentMethodState();
  }

  Future<void> loadPaymentData() async {
    try {
      final balance = await ref.read(getWalletBalanceUsecaseProvider).call();
      final methods = await ref.read(getPaymentMethodsUsecaseProvider).call();
      String? preferredLabel;
      for (final method in methods) {
        if (method.isDefault) {
          preferredLabel = method.label;
          break;
        }
      }
      preferredLabel ??= methods.isNotEmpty ? methods.first.label : null;
      state = state.copyWith(
        ryduCashBalance: balance,
        selectedPaymentMethod: preferredLabel ?? state.selectedPaymentMethod,
        clearError: true,
      );
    } catch (_) {
      // Keep defaults on failure.
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset({String paymentMethod = ''}) {
    state = PaymentMethodState(selectedPaymentMethod: paymentMethod);
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method, clearError: true);
  }

  void selectAccountType(String type) {
    if (type != PaymentAccountTypes.personal &&
        type != PaymentAccountTypes.business) {
      return;
    }
    state = state.copyWith(selectedAccountType: type, clearError: true);
  }

  void toggleRyduBalance(bool value) {
    // TODO: Sync RYD U balance toggle with wallet / ledger API when ready.
    state = state.copyWith(isRyduBalanceEnabled: value, clearError: true);
  }

  void setVoucherCode(String? code) {
    if (code == null || code.isEmpty) {
      state = state.copyWith(clearVoucherCode: true, clearError: true);
    } else {
      state = state.copyWith(selectedVoucherCode: code, clearError: true);
    }
  }

  void openAddPaymentMethod() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.addCard);
  }

  void openVoucherDetails() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.voucherDetails);
  }

  void openAddVoucher() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.addVoucher);
  }
}
