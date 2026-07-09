import '../models/profile_model.dart';

abstract interface class ProfileRemoteDatasource {
  Future<ProfileModel> fetchProfile();

  Future<void> saveProfile(ProfileModel model);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  ProfileRemoteDatasourceImpl();

  @override
  Future<ProfileModel> fetchProfile() async =>
      const ProfileModel(userId: 'user_placeholder');

  @override
  Future<void> saveProfile(ProfileModel model) async {}
}
