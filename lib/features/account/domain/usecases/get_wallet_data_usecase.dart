import '../entities/wallet_data_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletDataUsecase {
  GetWalletDataUsecase(this._repository);

  final WalletRepository _repository;

  Future<WalletDataEntity> call() => _repository.getWalletData();
}
