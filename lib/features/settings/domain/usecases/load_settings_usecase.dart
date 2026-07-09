import '../entities/app_settings_entity.dart';
import '../repositories/settings_repository.dart';

class LoadSettingsUsecase {
  LoadSettingsUsecase(this._repository);

  final SettingsRepository _repository;

  Future<AppSettingsEntity> call() => _repository.load();
}
