import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local);

  final SettingsLocalDatasource _local;

  @override
  Future<AppSettingsEntity> load() async {
    final model = await _local.read();
    return AppSettingsEntity(notificationsEnabled: model.notificationsEnabled);
  }

  @override
  Future<void> save(AppSettingsEntity settings) {
    return _local.write(
      AppSettingsModel(notificationsEnabled: settings.notificationsEnabled),
    );
  }
}
