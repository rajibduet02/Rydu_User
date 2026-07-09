import '../entities/active_ride_entity.dart';
import '../repositories/ride_tracking_repository.dart';

class WatchActiveRideUsecase {
  WatchActiveRideUsecase(this._repository);

  final RideTrackingRepository _repository;

  Stream<ActiveRideEntity> call(String rideId) {
    return _repository.watchRide(rideId);
  }
}
