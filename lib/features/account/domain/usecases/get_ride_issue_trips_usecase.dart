import '../entities/ride_trip_entity.dart';
import '../repositories/support_repository.dart';

class GetRideIssueTripsUsecase {
  GetRideIssueTripsUsecase(this._repository);

  final SupportRepository _repository;

  Future<List<RideTripEntity>> call() => _repository.getRideIssueTrips();
}
