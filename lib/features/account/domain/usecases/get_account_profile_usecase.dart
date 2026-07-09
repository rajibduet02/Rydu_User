import '../entities/account_profile_entity.dart';
import '../repositories/account_repository.dart';

class GetAccountProfileUsecase {
  GetAccountProfileUsecase(this._repository);

  final AccountRepository _repository;

  Future<AccountProfileEntity> call() => _repository.getAccountProfile();
}
