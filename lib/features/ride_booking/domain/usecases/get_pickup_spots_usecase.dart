import '../entities/pickup_spot_entity.dart';
import '../repositories/ride_booking_repository.dart';

class GetPickupSpotsUsecase {
  const GetPickupSpotsUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<List<PickupSpotEntity>> call() => _repository.getPickupSpots();
}
