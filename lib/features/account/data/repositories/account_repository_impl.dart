import '../../domain/entities/account_profile_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._local);

  final AccountLocalDatasource _local;

  @override
  Future<AccountProfileEntity> getAccountProfile() async {
    final model = await _local.fetchAccountProfile();
    return model.toEntity();
  }
}
