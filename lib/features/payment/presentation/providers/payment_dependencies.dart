import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/payment_local_datasource.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/add_card_usecase.dart';
import '../../domain/usecases/add_voucher_usecase.dart';
import '../../domain/usecases/get_payment_methods_usecase.dart';
import '../../domain/usecases/get_wallet_balance_usecase.dart';
import '../../domain/usecases/list_payment_methods_usecase.dart';
import '../../domain/usecases/select_payment_method_usecase.dart';

final paymentLocalDatasourceProvider = Provider<PaymentLocalDatasource>((ref) {
  return PaymentLocalDatasourceImpl();
});

final paymentRemoteDatasourceProvider = Provider<PaymentRemoteDatasource>((
  ref,
) {
  return PaymentRemoteDatasourceImpl();
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    localDatasource: ref.watch(paymentLocalDatasourceProvider),
    remoteDatasource: ref.watch(paymentRemoteDatasourceProvider),
  );
});

final getPaymentMethodsUsecaseProvider = Provider<GetPaymentMethodsUsecase>((
  ref,
) {
  return GetPaymentMethodsUsecase(ref.watch(paymentRepositoryProvider));
});

final listPaymentMethodsUsecaseProvider = Provider<ListPaymentMethodsUsecase>((
  ref,
) {
  return ListPaymentMethodsUsecase(ref.watch(paymentRepositoryProvider));
});

final selectPaymentMethodUsecaseProvider = Provider<SelectPaymentMethodUsecase>(
  (ref) {
    return SelectPaymentMethodUsecase(ref.watch(paymentRepositoryProvider));
  },
);

final addCardUsecaseProvider = Provider<AddCardUsecase>((ref) {
  return AddCardUsecase(ref.watch(paymentRepositoryProvider));
});

final getWalletBalanceUsecaseProvider = Provider<GetWalletBalanceUsecase>((
  ref,
) {
  return GetWalletBalanceUsecase(ref.watch(paymentRepositoryProvider));
});

final addVoucherUsecaseProvider = Provider<AddVoucherUsecase>((ref) {
  return AddVoucherUsecase(ref.watch(paymentRepositoryProvider));
});
