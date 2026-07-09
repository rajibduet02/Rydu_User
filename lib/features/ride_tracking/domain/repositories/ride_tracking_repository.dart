import '../entities/active_ride_entity.dart';
import '../entities/trip_tracking_entity.dart';

abstract interface class RideTrackingRepository {
  Stream<ActiveRideEntity> watchRide(String rideId);

  Future<void> simulateFindingDriverDelay();

  Future<TripTrackingEntity> getDriverFoundTrip({
    String? vehicleName,
    String? estimatedFare,
    String? paymentMethod,
  });

  Future<void> cancelRide();

  Future<void> shareTripStatus();

  Future<void> contactDriver();
}
