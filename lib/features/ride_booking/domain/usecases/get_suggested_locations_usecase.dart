import '../entities/ride_destination_entity.dart';
import '../repositories/ride_booking_repository.dart';

class GetSuggestedLocationsUsecase {
  const GetSuggestedLocationsUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<List<RideDestinationEntity>> call() {
    return _repository.getSuggestedLocations();
  }
}
