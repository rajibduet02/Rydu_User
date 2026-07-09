import '../entities/profile_details_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileDetailsUsecase {
  GetProfileDetailsUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileDetailsEntity> call() => _repository.getProfileDetails();
}
