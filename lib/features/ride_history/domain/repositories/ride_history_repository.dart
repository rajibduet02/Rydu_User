import '../entities/ride_history_item_entity.dart';

abstract interface class RideHistoryRepository {
  Future<List<RideHistoryItemEntity>> listRides();

  Future<RideHistoryItemEntity?> getRide(String id);
}
