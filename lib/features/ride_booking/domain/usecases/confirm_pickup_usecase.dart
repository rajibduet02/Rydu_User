import '../entities/ride_booking_entity.dart';
import '../repositories/ride_booking_repository.dart';

class ConfirmPickupUsecase {
  const ConfirmPickupUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<void> call(RideBookingEntity booking) {
    return _repository.confirmPickup(booking: booking);
  }
}
