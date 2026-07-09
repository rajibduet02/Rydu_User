abstract interface class ReserveLocalDatasource {
  bool isReserveEnabled();
}

class ReserveLocalDatasourceImpl implements ReserveLocalDatasource {
  @override
  bool isReserveEnabled() => true;
}
