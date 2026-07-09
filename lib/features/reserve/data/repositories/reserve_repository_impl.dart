import '../../domain/repositories/reserve_repository.dart';
import '../datasources/reserve_local_datasource.dart';

class ReserveRepositoryImpl implements ReserveRepository {
  ReserveRepositoryImpl(this._localDatasource);

  final ReserveLocalDatasource _localDatasource;

  @override
  bool canStartReserveRide() => _localDatasource.isReserveEnabled();
}
