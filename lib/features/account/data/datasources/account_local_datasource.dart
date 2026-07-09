import '../models/account_profile_model.dart';

abstract interface class AccountLocalDatasource {
  Future<AccountProfileModel> fetchAccountProfile();
}

class AccountLocalDatasourceImpl implements AccountLocalDatasource {
  @override
  Future<AccountProfileModel> fetchAccountProfile() async {
    // TODO: Load from API / cache when backend is ready.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const AccountProfileModel(
      userName: 'Mir Efaj',
      membershipName: 'RYD U One',
      rating: '5.0',
      rideCount: 127,
      walletBalance: 'BDT 250.00',
      hasUnreadInbox: true,
      savedPlacesCount: 4,
      appVersion: 'v4.629.10001',
    );
  }
}
