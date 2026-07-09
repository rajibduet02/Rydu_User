import '../repositories/family_repository.dart';

class PrepareAdultFamilyProfileUsecase {
  PrepareAdultFamilyProfileUsecase(this._repository);

  final FamilyRepository _repository;

  Future<void> call() => _repository.prepareAdultProfile();
}
