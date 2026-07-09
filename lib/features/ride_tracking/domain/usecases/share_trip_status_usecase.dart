import '../repositories/ride_tracking_repository.dart';

class ShareTripStatusUsecase {
  const ShareTripStatusUsecase(this._repository);

  final RideTrackingRepository _repository;

  Future<void> call() => _repository.shareTripStatus();
}
