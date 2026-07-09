import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_local_datasource.dart';

class SplashRepositoryImpl implements SplashRepository {
  SplashRepositoryImpl(this._local);

  final SplashLocalDatasource _local;

  @override
  Future<bool> isFirstLaunch() => _local.readFirstLaunchFlag();
}
