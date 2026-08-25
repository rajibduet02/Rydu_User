import '../entities/passenger_profile.dart';

class PassengerProfilePhoneUpdate {
  const PassengerProfilePhoneUpdate.set({
    required this.countryCode,
    required this.number,
  }) : clear = false;

  const PassengerProfilePhoneUpdate.clear()
    : countryCode = '',
      number = '',
      clear = true;

  final String countryCode;
  final String number;
  final bool clear;
}

abstract interface class PassengerProfileRepository {
  Future<PassengerProfile> getProfile();

  Future<PassengerProfile> updateProfile({
    String? name,
    PassengerProfilePhoneUpdate? phone,
  });

  Future<PassengerProfile> uploadAvatar({
    required String filePath,
    String? filename,
    String? mimeType,
  });

  Future<PassengerProfile> deleteAvatar();

  Future<void> deactivate({required bool confirm});
}
