import '../repositories/ride_booking_repository.dart';

class GetPickupSpotLabelUsecase {
  const GetPickupSpotLabelUsecase(this._repository);

  final RideBookingRepository _repository;

  String call(int index) => _repository.pickupSpotLabel(index);
}
