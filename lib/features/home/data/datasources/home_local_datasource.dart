abstract interface class HomeLocalDatasource {
  Future<String> resolveCurrentLocationLabel();
}

class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  @override
  Future<String> resolveCurrentLocationLabel() async {
    // TODO: Wire geolocator + permission_handler when packages are configured.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return 'Current location';
  }
}
