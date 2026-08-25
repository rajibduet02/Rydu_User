import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../entities/ride_history_page.dart';
import '../repositories/ride_history_repository.dart';
import '../ride_history_filter.dart';

class ListRideHistoryUsecase {
  ListRideHistoryUsecase(this._repository);

  final RideHistoryRepository _repository;

  Future<RideHistoryPage> call({
    required int page,
    required int limit,
    required RideHistoryFilter filter,
  }) {
    return _repository.listRides(page: page, limit: limit, filter: filter);
  }
}

class GetRideDetailsUsecase {
  GetRideDetailsUsecase(this._repository);

  final RideHistoryRepository _repository;

  Future<BookingEntity?> call(String id) => _repository.getRide(id);
}
