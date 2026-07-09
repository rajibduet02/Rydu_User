abstract interface class SplashLocalDatasource {
  Future<bool> readFirstLaunchFlag();
}

class SplashLocalDatasourceImpl implements SplashLocalDatasource {
  SplashLocalDatasourceImpl();

  @override
  Future<bool> readFirstLaunchFlag() async => true;
}
