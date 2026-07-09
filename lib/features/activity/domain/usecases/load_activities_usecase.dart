import '../entities/activity_item_entity.dart';
import '../repositories/activity_repository.dart';

class LoadActivitiesUsecase {
  LoadActivitiesUsecase(this._repository);

  final ActivityRepository _repository;

  Future<List<ActivityItemEntity>> call({
    required String category,
    required String service,
  }) {
    return _repository.fetchActivities(category: category, service: service);
  }
}
