class AccountSettingsEntity {
  const AccountSettingsEntity({
    required this.notificationsEnabled,
    required this.selectedLanguage,
    required this.appVersion,
  });

  final bool notificationsEnabled;
  final String selectedLanguage;
  final String appVersion;
}
