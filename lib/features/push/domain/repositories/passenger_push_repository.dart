abstract interface class PassengerPushRepository {
  Future<void> registerToken({required String token, required String deviceId});

  Future<void> unregisterToken();
}
