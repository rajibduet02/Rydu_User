import '../repositories/ride_booking_repository.dart';

class GetDefaultPickupLocationUsecase {
  const GetDefaultPickupLocationUsecase(this._repository);

  final RideBookingRepository _repository;

  String call() => _repository.getDefaultPickupLocation();
}
