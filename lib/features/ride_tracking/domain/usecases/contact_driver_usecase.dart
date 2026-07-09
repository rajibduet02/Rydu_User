import '../repositories/ride_tracking_repository.dart';

class ContactDriverUsecase {
  const ContactDriverUsecase(this._repository);

  final RideTrackingRepository _repository;

  Future<void> call() => _repository.contactDriver();
}
