import '../models/account_settings_model.dart';

abstract interface class AccountSettingsLocalDatasource {
  Future<AccountSettingsModel> fetchSettings();
}

class AccountSettingsLocalDatasourceImpl
    implements AccountSettingsLocalDatasource {
  @override
  Future<AccountSettingsModel> fetchSettings() async {
    // TODO: Load other preferences from secure storage / profile API when available.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const AccountSettingsModel(
      notificationsEnabled: true,
      selectedLanguage: 'English (US)',
      appVersion: '4.629.10001',
    );
  }
}
