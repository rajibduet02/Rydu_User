import '../entities/fare_estimate_entity.dart';
import '../repositories/ride_booking_repository.dart';

class EstimateFareUsecase {
  const EstimateFareUsecase(this._repository);

  final RideBookingRepository _repository;

  Future<FareEstimateEntity> call({
    required String rideType,
    required String optionId,
  }) {
    return _repository.estimateFare(rideType: rideType, optionId: optionId);
  }
}
