import '../entities/app_settings_entity.dart';

abstract interface class SettingsRepository {
  Future<AppSettingsEntity> load();

  Future<void> save(AppSettingsEntity settings);
}
