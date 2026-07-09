import '../entities/ride_option_entity.dart';
import '../repositories/ride_booking_repository.dart';

class SelectRideOptionUsecase {
  const SelectRideOptionUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<RideOptionEntity?> call(String optionId) {
    return _repository.findRideOptionById(optionId);
  }
}
