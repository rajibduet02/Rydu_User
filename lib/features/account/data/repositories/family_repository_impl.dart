import '../../domain/repositories/family_repository.dart';
import '../datasources/family_local_datasource.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  FamilyRepositoryImpl(this._local);

  final FamilyLocalDatasource _local;

  @override
  Future<void> prepareAdultProfile() => _local.prepareAdultProfile();

  @override
  Future<void> prepareTeenProfile() => _local.prepareTeenProfile();

  @override
  Future<void> continueFamilyMemberFlow(String memberType) =>
      _local.continueFamilyMemberFlow(memberType);

  @override
  Future<void> sendGuardianInvite({
    required String name,
    required String countryCode,
    required String phoneNumber,
  }) => _local.sendGuardianInvite(
    name: name,
    countryCode: countryCode,
    phoneNumber: phoneNumber,
  );

  @override
  Future<void> sendTeenInvite({
    required String name,
    required String countryCode,
    required String phoneNumber,
    required DateTime dateOfBirth,
  }) => _local.sendTeenInvite(
    name: name,
    countryCode: countryCode,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
  );
}
