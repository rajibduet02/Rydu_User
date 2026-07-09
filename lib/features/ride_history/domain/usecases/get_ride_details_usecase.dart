import '../entities/ride_history_item_entity.dart';
import '../repositories/ride_history_repository.dart';

class GetRideDetailsUsecase {
  GetRideDetailsUsecase(this._repository);

  final RideHistoryRepository _repository;

  Future<RideHistoryItemEntity?> call(String id) => _repository.getRide(id);
}
