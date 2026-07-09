import '../entities/ride_booking_entity.dart';
import '../repositories/ride_booking_repository.dart';

class CreateRideRequestUsecase {
  const CreateRideRequestUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<String> call(RideBookingEntity booking) {
    return _repository.createRideRequest(booking: booking);
  }
}
