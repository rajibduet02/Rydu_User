import '../../domain/entities/fare_estimate_entity.dart';
import '../../domain/entities/pickup_spot_entity.dart';
import '../../domain/entities/ride_booking_entity.dart';
import '../../domain/entities/ride_destination_entity.dart';
import '../../domain/entities/ride_option_entity.dart';
import '../../domain/repositories/ride_booking_repository.dart';
import '../datasources/ride_booking_local_datasource.dart';
import '../datasources/ride_booking_remote_datasource.dart';

class RideBookingRepositoryImpl implements RideBookingRepository {
  RideBookingRepositoryImpl({
    required RideBookingLocalDatasource localDatasource,
    required RideBookingRemoteDatasource remoteDatasource,
  }) : _local = localDatasource,
       _remote = remoteDatasource;

  final RideBookingLocalDatasource _local;
  final RideBookingRemoteDatasource _remote;

  @override
  String getDefaultPickupLocation() => _local.getDefaultPickupLocation();

  @override
  Future<List<RideDestinationEntity>> getSuggestedLocations() {
    return _local.fetchSuggestedLocations();
  }

  @override
  Future<RideDestinationEntity?> findDestinationById(String id) async {
    final list = await _local.fetchSuggestedLocations();
    for (final item in list) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<RideOptionEntity>> getRideOptions() {
    return _local.fetchRideOptions();
  }

  @override
  Future<RideOptionEntity?> findRideOptionById(String id) async {
    final list = await _local.fetchRideOptions();
    for (final item in list) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<PickupSpotEntity>> getPickupSpots() async {
    return _local.getPickupSpots();
  }

  @override
  String pickupSpotLabel(int index) {
    final spots = _local.getPickupSpots();
    if (index < 0 || index >= spots.length) return spots.first.label;
    return spots[index].label;
  }

  @override
  Future<FareEstimateEntity> estimateFare({
    required String rideType,
    required String optionId,
  }) async {
    final option = await findRideOptionById(optionId);
    if (option == null) {
      return const FareEstimateEntity(displayFare: 'BDT 0.00');
    }
    // TODO: Use remote fare API when rideType + optionId pricing is available.
    return FareEstimateEntity(displayFare: option.price);
  }

  @override
  Future<void> confirmPickup({required RideBookingEntity booking}) {
    return _local.simulateConfirmPickupDelay();
  }

  @override
  Future<String> createRideRequest({required RideBookingEntity booking}) {
    return _local.simulateCreateRideRequest();
  }

  @override
  Future<String> createRideDraft() async {
    final draft = await _remote.createDraft();
    return draft.id;
  }

  @override
  Future<void> confirmRide({required String rideDraftId}) {
    return _remote.confirm(rideDraftId);
  }
}
