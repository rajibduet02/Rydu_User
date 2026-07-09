import 'driver_entity.dart';

class TripTrackingEntity {
  const TripTrackingEntity({
    required this.rideId,
    required this.tripStatus,
    required this.driver,
    required this.estimatedFare,
    required this.paymentMethod,
  });

  final String rideId;
  final String tripStatus;
  final DriverEntity driver;
  final String estimatedFare;
  final String paymentMethod;
}
