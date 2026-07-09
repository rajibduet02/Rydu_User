import '../../domain/entities/payment_method_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_datasource.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({
    required PaymentLocalDatasource localDatasource,
    required PaymentRemoteDatasource remoteDatasource,
  }) : _local = localDatasource,
       _remote = remoteDatasource;

  final PaymentLocalDatasource _local;
  final PaymentRemoteDatasource _remote;

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() async {
    final local = await _local.fetchMethods();
    if (local.isNotEmpty) return local;
    final remote = await _remote.fetchMethods();
    return remote
        .map(
          (m) => PaymentMethodEntity(
            id: m.id,
            label: m.label,
            isDefault: m.isDefault,
          ),
        )
        .toList();
  }

  @override
  Future<double> getWalletBalance() => _local.fetchRyduCashBalance();

  @override
  Future<void> addCard({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  }) async {
    // TODO: POST card to payment API.
    await _local.simulateAddCardDelay();
  }

  @override
  Future<void> addVoucher(String code) async {
    // TODO: Validate voucher via API.
    await _local.simulateAddVoucherDelay();
  }
}
