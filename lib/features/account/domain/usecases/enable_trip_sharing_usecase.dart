import '../entities/safety_center_data_entity.dart';
import '../repositories/security_repository.dart';

class EnableTripSharingUsecase {
  EnableTripSharingUsecase(this._repository);

  final SecurityRepository _repository;

  Future<SafetyCenterDataEntity> call() => _repository.enableTripSharing();
}
