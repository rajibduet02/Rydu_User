import '../entities/account_settings_entity.dart';
import '../repositories/account_settings_repository.dart';

class GetAccountSettingsUsecase {
  GetAccountSettingsUsecase(this._repository);

  final AccountSettingsRepository _repository;

  Future<AccountSettingsEntity> call() => _repository.getSettings();
}
