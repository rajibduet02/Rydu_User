import '../entities/activity_item_entity.dart';

abstract interface class ActivityRepository {
  Future<List<ActivityItemEntity>> fetchActivities({
    required String category,
    required String service,
  });
}
