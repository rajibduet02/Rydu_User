import '../../domain/entities/home_summary_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote, this._local);

  final HomeRemoteDatasource _remote;
  final HomeLocalDatasource _local;

  @override
  Future<HomeSummaryEntity> loadSummary() async {
    final model = await _remote.fetchSummary();
    return HomeSummaryEntity(activeRideId: model.activeRideId);
  }

  @override
  Future<String> resolveCurrentLocationLabel() =>
      _local.resolveCurrentLocationLabel();
}
