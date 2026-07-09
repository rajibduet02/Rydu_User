import '../../domain/entities/wallet_data_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._local);

  final WalletLocalDatasource _local;

  @override
  Future<WalletDataEntity> getWalletData() async {
    final model = await _local.fetchWalletData();
    return model.toEntity();
  }
}
