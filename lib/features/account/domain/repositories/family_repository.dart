abstract interface class FamilyRepository {
  Future<void> prepareAdultProfile();
  Future<void> prepareTeenProfile();
  Future<void> continueFamilyMemberFlow(String memberType);
  Future<void> sendGuardianInvite({
    required String name,
    required String countryCode,
    required String phoneNumber,
  });
  Future<void> sendTeenInvite({
    required String name,
    required String countryCode,
    required String phoneNumber,
    required DateTime dateOfBirth,
  });
}
