import '../repositories/family_repository.dart';

class SendTeenInviteUsecase {
  SendTeenInviteUsecase(this._repository);

  final FamilyRepository _repository;

  Future<void> call({
    required String name,
    required String countryCode,
    required String phoneNumber,
    required DateTime dateOfBirth,
  }) => _repository.sendTeenInvite(
    name: name,
    countryCode: countryCode,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
  );
}
