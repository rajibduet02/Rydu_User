import '../../domain/entities/activity_item_entity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_datasource.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._local);

  final ActivityLocalDatasource _local;

  @override
  Future<List<ActivityItemEntity>> fetchActivities({
    required String category,
    required String service,
  }) async {
    final models = await _local.fetchActivities(
      category: category,
      service: service,
    );
    return models.map((m) => m.toEntity()).toList(growable: false);
  }
}
