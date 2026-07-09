import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/trip_tracking_entity.dart';

abstract interface class RideTrackingLocalDatasource {
  Future<void> simulateFindingDriverDelay();

  Future<TripTrackingEntity> fetchDriverFoundTrip({
    String? vehicleName,
    String? estimatedFare,
    String? paymentMethod,
  });

  Future<void> simulateCancelRideDelay();

  Future<void> simulateShareTrip();

  Future<void> simulateContactDriver();
}

class RideTrackingLocalDatasourceImpl implements RideTrackingLocalDatasource {
  static const _defaultDriver = DriverEntity(
    name: 'MOHAMMAD MOHIDUL ISLAM',
    rating: '4.9',
    vehicleName: 'CNG',
    plateNumber: 'DHM-LA-63-525',
    eta: '2 min',
  );

  @override
  Future<void> simulateFindingDriverDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  @override
  Future<TripTrackingEntity> fetchDriverFoundTrip({
    String? vehicleName,
    String? estimatedFare,
    String? paymentMethod,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return TripTrackingEntity(
      rideId: 'BDT12138',
      tripStatus: 'Active',
      driver: DriverEntity(
        name: _defaultDriver.name,
        rating: _defaultDriver.rating,
        vehicleName: vehicleName ?? _defaultDriver.vehicleName,
        plateNumber: _defaultDriver.plateNumber,
        eta: _defaultDriver.eta,
      ),
      estimatedFare: estimatedFare ?? 'BDT 155.84',
      paymentMethod: paymentMethod ?? 'Cash',
    );
  }

  @override
  Future<void> simulateCancelRideDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> simulateShareTrip() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> simulateContactDriver() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}
