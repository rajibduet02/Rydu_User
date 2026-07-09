import '../../domain/entities/account_settings_entity.dart';

class AccountSettingsModel extends AccountSettingsEntity {
  const AccountSettingsModel({
    required super.notificationsEnabled,
    required super.selectedLanguage,
    required super.appVersion,
  });

  AccountSettingsEntity toEntity() => this;
}
