import '../entities/ride_option_entity.dart';
import '../repositories/ride_booking_repository.dart';

class GetRideOptionsUsecase {
  const GetRideOptionsUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<List<RideOptionEntity>> call() => _repository.getRideOptions();
}
