import '../entities/trip_tracking_entity.dart';
import '../repositories/ride_tracking_repository.dart';

class GetDriverFoundUsecase {
  const GetDriverFoundUsecase(this._repository);

  final RideTrackingRepository _repository;

  Future<TripTrackingEntity> call({
    String? vehicleName,
    String? estimatedFare,
    String? paymentMethod,
  }) {
    return _repository.getDriverFoundTrip(
      vehicleName: vehicleName,
      estimatedFare: estimatedFare,
      paymentMethod: paymentMethod,
    );
  }
}
