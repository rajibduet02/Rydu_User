import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDatasource _remote;

  ProfileEntity _map(ProfileModel m) {
    return ProfileEntity(
      userId: m.userId,
      displayName: m.displayName,
      phone: m.phone,
    );
  }

  @override
  Future<ProfileEntity> getProfile() async {
    final model = await _remote.fetchProfile();
    return _map(model);
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) {
    return _remote.saveProfile(
      ProfileModel(
        userId: profile.userId,
        displayName: profile.displayName,
        phone: profile.phone,
      ),
    );
  }
}
