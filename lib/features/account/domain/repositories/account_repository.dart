import '../entities/account_profile_entity.dart';

abstract interface class AccountRepository {
  Future<AccountProfileEntity> getAccountProfile();
}
