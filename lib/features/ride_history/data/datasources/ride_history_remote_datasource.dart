import '../models/ride_history_item_model.dart';

abstract interface class RideHistoryRemoteDatasource {
  Future<List<RideHistoryItemModel>> fetchRides();

  Future<RideHistoryItemModel?> fetchRide(String id);
}

class RideHistoryRemoteDatasourceImpl implements RideHistoryRemoteDatasource {
  RideHistoryRemoteDatasourceImpl();

  @override
  Future<List<RideHistoryItemModel>> fetchRides() async =>
      <RideHistoryItemModel>[];

  @override
  Future<RideHistoryItemModel?> fetchRide(String id) async => null;
}
