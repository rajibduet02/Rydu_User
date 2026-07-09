import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl(this._remote);

  final MapRemoteDatasource _remote;

  @override
  Future<void> prefetchTiles() => _remote.warmup();
}
