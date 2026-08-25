import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import 'pagination_meta.dart';

class RideHistoryPage {
  const RideHistoryPage({
    required this.items,
    required this.pagination,
  });

  final List<BookingEntity> items;
  final PaginationMeta pagination;
}
