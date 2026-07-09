import '../repositories/family_repository.dart';

class ContinueFamilyMemberFlowUsecase {
  ContinueFamilyMemberFlowUsecase(this._repository);

  final FamilyRepository _repository;

  Future<void> call(String memberType) =>
      _repository.continueFamilyMemberFlow(memberType);
}
