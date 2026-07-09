import '../../domain/entities/ride_history_item_entity.dart';
import '../../domain/repositories/ride_history_repository.dart';
import '../datasources/ride_history_remote_datasource.dart';
import '../models/ride_history_item_model.dart';

class RideHistoryRepositoryImpl implements RideHistoryRepository {
  RideHistoryRepositoryImpl(this._remote);

  final RideHistoryRemoteDatasource _remote;

  RideHistoryItemEntity _map(RideHistoryItemModel m) {
    return RideHistoryItemEntity(
      id: m.id,
      summary: m.summary,
      completedAt: m.completedAt,
    );
  }

  @override
  Future<List<RideHistoryItemEntity>> listRides() async {
    final models = await _remote.fetchRides();
    return models.map(_map).toList();
  }

  @override
  Future<RideHistoryItemEntity?> getRide(String id) async {
    final model = await _remote.fetchRide(id);
    return model == null ? null : _map(model);
  }
}
