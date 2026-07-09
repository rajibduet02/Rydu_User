import '../repositories/family_repository.dart';

class PrepareTeenFamilyProfileUsecase {
  PrepareTeenFamilyProfileUsecase(this._repository);

  final FamilyRepository _repository;

  Future<void> call() => _repository.prepareTeenProfile();
}
