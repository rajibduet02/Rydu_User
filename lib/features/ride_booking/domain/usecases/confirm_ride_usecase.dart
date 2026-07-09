import '../repositories/ride_booking_repository.dart';

class ConfirmRideUsecase {
  const ConfirmRideUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<void> call({required String rideDraftId}) {
    return _repository.confirmRide(rideDraftId: rideDraftId);
  }
}
