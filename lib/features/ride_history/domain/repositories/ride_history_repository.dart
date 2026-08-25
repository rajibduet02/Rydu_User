import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../entities/ride_history_page.dart';
import '../ride_history_filter.dart';

abstract interface class RideHistoryRepository {
  Future<RideHistoryPage> listRides({
    required int page,
    required int limit,
    required RideHistoryFilter filter,
  });

  Future<BookingEntity?> getRide(String id);
}
