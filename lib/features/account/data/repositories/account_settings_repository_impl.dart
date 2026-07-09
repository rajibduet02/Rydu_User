import '../../domain/entities/account_settings_entity.dart';
import '../../domain/repositories/account_settings_repository.dart';
import '../datasources/account_settings_local_datasource.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {
  AccountSettingsRepositoryImpl(this._local);

  final AccountSettingsLocalDatasource _local;

  @override
  Future<AccountSettingsEntity> getSettings() async {
    final model = await _local.fetchSettings();
    return model.toEntity();
  }
}
