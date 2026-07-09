import '../repositories/ride_tracking_repository.dart';

class StartFindingDriverUsecase {
  const StartFindingDriverUsecase(this._repository);

  final RideTrackingRepository _repository;

  Future<void> call() => _repository.simulateFindingDriverDelay();
}
