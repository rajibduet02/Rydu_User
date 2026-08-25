import '../../domain/repositories/passenger_push_repository.dart';
import '../datasources/passenger_push_remote_datasource.dart';

class PassengerPushRepositoryImpl implements PassengerPushRepository {
  PassengerPushRepositoryImpl(this._remote);

  final PassengerPushRemoteDatasource _remote;

  @override
  Future<void> registerToken({
    required String token,
    required String deviceId,
  }) {
    return _remote.registerToken(token: token, deviceId: deviceId);
  }

  @override
  Future<void> unregisterToken() => _remote.unregisterToken();
}
