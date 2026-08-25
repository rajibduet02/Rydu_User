import 'package:dio/dio.dart';

import '../../domain/entities/passenger_profile.dart';

abstract interface class PassengerProfileRemoteDatasource {
  Future<PassengerProfile> fetchProfile();

  Future<PassengerProfile> patchProfile(Map<String, dynamic> body);

  Future<PassengerProfile> uploadAvatar(FormData formData);

  Future<PassengerProfile> deleteAvatar();

  Future<void> deactivate({required bool confirm});
}
