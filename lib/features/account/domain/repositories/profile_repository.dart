import '../entities/profile_details_entity.dart';

abstract interface class ProfileRepository {
  Future<ProfileDetailsEntity> getProfileDetails();
}
