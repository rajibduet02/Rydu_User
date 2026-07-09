import '../repositories/map_repository.dart';

class PrefetchMapTilesUsecase {
  PrefetchMapTilesUsecase(this._repository);

  final MapRepository _repository;

  Future<void> call() => _repository.prefetchTiles();
}
