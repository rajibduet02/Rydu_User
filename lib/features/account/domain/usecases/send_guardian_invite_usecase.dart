import '../repositories/family_repository.dart';

class SendGuardianInviteUsecase {
  SendGuardianInviteUsecase(this._repository);

  final FamilyRepository _repository;

  Future<void> call({
    required String name,
    required String countryCode,
    required String phoneNumber,
  }) => _repository.sendGuardianInvite(
    name: name,
    countryCode: countryCode,
    phoneNumber: phoneNumber,
  );
}
