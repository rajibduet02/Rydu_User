import '../models/app_settings_model.dart';

abstract interface class SettingsLocalDatasource {
  Future<AppSettingsModel> read();

  Future<void> write(AppSettingsModel model);
}

class SettingsLocalDatasourceImpl implements SettingsLocalDatasource {
  SettingsLocalDatasourceImpl();

  @override
  Future<AppSettingsModel> read() async => const AppSettingsModel();

  @override
  Future<void> write(AppSettingsModel model) async {}
}
