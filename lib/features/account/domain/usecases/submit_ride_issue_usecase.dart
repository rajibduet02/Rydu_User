import '../entities/ride_trip_entity.dart';
import '../repositories/support_repository.dart';

class SubmitRideIssueUsecase {
  SubmitRideIssueUsecase(this._repository);

  final SupportRepository _repository;

  Future<void> call({
    required RideTripEntity trip,
    required String issueType,
    required String details,
    String? photoPath,
  }) => _repository.submitRideIssue(
    trip: trip,
    issueType: issueType,
    details: details,
    photoPath: photoPath,
  );
}
