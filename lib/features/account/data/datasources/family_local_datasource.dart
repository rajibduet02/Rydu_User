abstract interface class FamilyLocalDatasource {
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

class FamilyLocalDatasourceImpl implements FamilyLocalDatasource {
  @override
  Future<void> prepareAdultProfile() async {
    // TODO: Create adult family profile via backend API when ready.
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> prepareTeenProfile() async {
    // TODO: Start teen family profile invite flow via backend API when ready.
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> continueFamilyMemberFlow(String memberType) async {
    // TODO: Persist selected member type when family API is ready.
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  @override
  Future<void> sendGuardianInvite({
    required String name,
    required String countryCode,
    required String phoneNumber,
  }) async {
    // TODO: POST guardian invite to backend API when ready.
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> sendTeenInvite({
    required String name,
    required String countryCode,
    required String phoneNumber,
    required DateTime dateOfBirth,
  }) async {
    // TODO: POST family teen invite to backend API when ready.
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
