import '../entities/account_settings_entity.dart';

abstract interface class AccountSettingsRepository {
  Future<AccountSettingsEntity> getSettings();
}
