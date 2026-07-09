import '../models/activity_item_model.dart';

abstract interface class ActivityLocalDatasource {
  Future<List<ActivityItemModel>> fetchActivities({
    required String category,
    required String service,
  });
}

class ActivityLocalDatasourceImpl implements ActivityLocalDatasource {
  @override
  Future<List<ActivityItemModel>> fetchActivities({
    required String category,
    required String service,
  }) async {
    // TODO: Replace with paginated activity API using category/service filters.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [];
  }
}
