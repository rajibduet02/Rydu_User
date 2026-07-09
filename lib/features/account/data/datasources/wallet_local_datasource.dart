import '../models/wallet_data_model.dart';

abstract interface class WalletLocalDatasource {
  Future<WalletDataModel> fetchWalletData();
}

class WalletLocalDatasourceImpl implements WalletLocalDatasource {
  @override
  Future<WalletDataModel> fetchWalletData() async {
    // TODO: Fetch wallet balance, cards, and transactions from payment API.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return WalletDataModel.fromSeed();
  }
}
