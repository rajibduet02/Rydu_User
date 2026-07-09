import '../models/ride_draft_model.dart';

abstract interface class RideBookingRemoteDatasource {
  Future<RideDraftModel> createDraft();

  Future<double> estimateFare(String draftId);

  Future<void> confirm(String draftId);
}

class RideBookingRemoteDatasourceImpl implements RideBookingRemoteDatasource {
  RideBookingRemoteDatasourceImpl();

  @override
  Future<RideDraftModel> createDraft() async =>
      const RideDraftModel(id: 'draft_placeholder');

  @override
  Future<double> estimateFare(String draftId) async => 0;

  @override
  Future<void> confirm(String draftId) async {}
}
