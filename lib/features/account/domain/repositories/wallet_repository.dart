import '../entities/wallet_data_entity.dart';

abstract interface class WalletRepository {
  Future<WalletDataEntity> getWalletData();
}
