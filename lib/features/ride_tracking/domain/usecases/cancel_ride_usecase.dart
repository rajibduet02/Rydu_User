import '../repositories/ride_tracking_repository.dart';

class CancelRideUsecase {
  const CancelRideUsecase(this._repository);

  final RideTrackingRepository _repository;

  Future<void> call() => _repository.cancelRide();
}
