import '../entities/fare_estimate_entity.dart';
import '../entities/pickup_spot_entity.dart';
import '../entities/ride_booking_entity.dart';
import '../entities/ride_destination_entity.dart';
import '../entities/ride_option_entity.dart';

abstract interface class RideBookingRepository {
  String getDefaultPickupLocation();

  Future<List<RideDestinationEntity>> getSuggestedLocations();

  Future<RideDestinationEntity?> findDestinationById(String id);

  Future<List<RideOptionEntity>> getRideOptions();

  Future<RideOptionEntity?> findRideOptionById(String id);

  Future<List<PickupSpotEntity>> getPickupSpots();

  String pickupSpotLabel(int index);

  Future<FareEstimateEntity> estimateFare({
    required String rideType,
    required String optionId,
  });

  Future<void> confirmPickup({required RideBookingEntity booking});

  Future<String> createRideRequest({required RideBookingEntity booking});

  Future<String> createRideDraft();

  Future<void> confirmRide({required String rideDraftId});
}
