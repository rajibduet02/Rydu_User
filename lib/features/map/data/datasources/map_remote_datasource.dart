abstract interface class MapRemoteDatasource {
  Future<void> warmup();
}

class MapRemoteDatasourceImpl implements MapRemoteDatasource {
  MapRemoteDatasourceImpl();

  @override
  Future<void> warmup() async {}
}
