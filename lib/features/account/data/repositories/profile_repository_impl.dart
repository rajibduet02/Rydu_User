import '../../domain/entities/profile_details_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._local);

  final ProfileLocalDatasource _local;

  @override
  Future<ProfileDetailsEntity> getProfileDetails() async {
    final model = await _local.fetchProfileDetails();
    return model.toEntity();
  }
}
