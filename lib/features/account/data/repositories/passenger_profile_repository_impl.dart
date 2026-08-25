import 'package:dio/dio.dart';

import '../../domain/entities/passenger_profile.dart';
import '../../domain/repositories/passenger_profile_repository.dart';
import '../datasources/passenger_profile_remote_datasource.dart';
import '../utils/passenger_profile_requests.dart';

class PassengerProfileRepositoryImpl implements PassengerProfileRepository {
  PassengerProfileRepositoryImpl(this._remote);

  final PassengerProfileRemoteDatasource _remote;

  @override
  Future<PassengerProfile> getProfile() => _remote.fetchProfile();

  @override
  Future<PassengerProfile> updateProfile({
    String? name,
    PassengerProfilePhoneUpdate? phone,
  }) {
    final body = <String, dynamic>{};
    if (name != null) {
      body.addAll(PassengerProfileRequests.patchName(name));
    }
    if (phone != null) {
      if (phone.clear) {
        body.addAll(PassengerProfileRequests.patchPhoneClear());
      } else {
        body.addAll(
          PassengerProfileRequests.patchPhone(
            countryCode: phone.countryCode,
            number: phone.number,
          ),
        );
      }
    }
    return _remote.patchProfile(body);
  }

  @override
  Future<PassengerProfile> uploadAvatar({
    required String filePath,
    String? filename,
    String? mimeType,
  }) {
    final name = filename ?? filePath.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      PassengerProfileRequests.avatarField: MultipartFile.fromFileSync(
        filePath,
        filename: name,
      ),
    });
    return _remote.uploadAvatar(formData);
  }

  @override
  Future<PassengerProfile> deleteAvatar() => _remote.deleteAvatar();

  @override
  Future<void> deactivate({required bool confirm}) =>
      _remote.deactivate(confirm: confirm);
}
