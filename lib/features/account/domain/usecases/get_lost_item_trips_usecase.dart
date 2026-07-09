import '../entities/lost_item_trip_entity.dart';
import '../repositories/support_repository.dart';

class GetLostItemTripsUsecase {
  GetLostItemTripsUsecase(this._repository);

  final SupportRepository _repository;

  Future<List<LostItemTripEntity>> call() => _repository.getLostItemTrips();
}
