import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../../domain/entities/ride_history_page.dart';
import '../../domain/repositories/ride_history_repository.dart';
import '../../domain/ride_history_filter.dart';
import '../datasources/ride_history_remote_datasource.dart';

class RideHistoryRepositoryImpl implements RideHistoryRepository {
  RideHistoryRepositoryImpl(this._remote);

  final RideHistoryRemoteDatasource _remote;

  @override
  Future<RideHistoryPage> listRides({
    required int page,
    required int limit,
    required RideHistoryFilter filter,
  }) {
    return _remote.fetchRides(page: page, limit: limit, filter: filter);
  }

  @override
  Future<BookingEntity?> getRide(String id) => _remote.fetchRide(id);
}
