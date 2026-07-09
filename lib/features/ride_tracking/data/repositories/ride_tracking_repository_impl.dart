import '../../domain/entities/active_ride_entity.dart';
import '../../domain/entities/trip_tracking_entity.dart';
import '../../domain/repositories/ride_tracking_repository.dart';
import '../datasources/ride_tracking_local_datasource.dart';
import '../datasources/ride_tracking_remote_datasource.dart';

class RideTrackingRepositoryImpl implements RideTrackingRepository {
  RideTrackingRepositoryImpl({
    required RideTrackingLocalDatasource localDatasource,
    required RideTrackingRemoteDatasource remoteDatasource,
  }) : _local = localDatasource,
       _remote = remoteDatasource;

  final RideTrackingLocalDatasource _local;
  final RideTrackingRemoteDatasource _remote;

  @override
  Stream<ActiveRideEntity> watchRide(String rideId) {
    return _remote
        .driverLocation(rideId)
        .map((_) => ActiveRideEntity(rideId: rideId, statusLabel: 'En route'));
  }

  @override
  Future<void> simulateFindingDriverDelay() {
    return _local.simulateFindingDriverDelay();
  }

  @override
  Future<TripTrackingEntity> getDriverFoundTrip({
    String? vehicleName,
    String? estimatedFare,
    String? paymentMethod,
  }) {
    return _local.fetchDriverFoundTrip(
      vehicleName: vehicleName,
      estimatedFare: estimatedFare,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<void> cancelRide() => _local.simulateCancelRideDelay();

  @override
  Future<void> shareTripStatus() => _local.simulateShareTrip();

  @override
  Future<void> contactDriver() => _local.simulateContactDriver();
}
