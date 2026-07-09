import '../../domain/entities/intercity_content_entity.dart';
import '../../domain/repositories/intercity_repository.dart';
import '../datasources/intercity_local_datasource.dart';

class IntercityRepositoryImpl implements IntercityRepository {
  IntercityRepositoryImpl(this._localDatasource);

  final IntercityLocalDatasource _localDatasource;

  @override
  Future<IntercityContentEntity> loadIntercityContent() {
    return _localDatasource.fetchIntercityContent();
  }
}
