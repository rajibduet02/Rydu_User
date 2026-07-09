import '../entities/lost_item_trip_entity.dart';
import '../repositories/support_repository.dart';

class SubmitLostItemReportUsecase {
  SubmitLostItemReportUsecase(this._repository);

  final SupportRepository _repository;

  Future<void> call({
    required LostItemTripEntity trip,
    required String itemDescription,
    required String lastSeenLocation,
    required String contactPreference,
  }) => _repository.submitLostItemReport(
    trip: trip,
    itemDescription: itemDescription,
    lastSeenLocation: lastSeenLocation,
    contactPreference: contactPreference,
  );
}
