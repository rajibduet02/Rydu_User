import '../entities/ride_destination_entity.dart';
import '../repositories/ride_booking_repository.dart';

class SelectDestinationUsecase {
  const SelectDestinationUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<RideDestinationEntity?> call(String locationId) {
    return _repository.findDestinationById(locationId);
  }
}
