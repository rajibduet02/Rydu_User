import '../../../auth/domain/exceptions/auth_exception.dart';
import '../../../auth/domain/usecases/get_me_usecase.dart';
import '../../domain/entities/profile_details_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/profile_details_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._local, this._getMe);

  final ProfileLocalDatasource _local;
  final GetMeUsecase _getMe;

  @override
  Future<ProfileDetailsEntity> getProfileDetails() async {
    final fallback = await _local.fetchProfileDetails();

    try {
      final user = await _getMe.call();
      if (user == null) return fallback.toEntity();

      return ProfileDetailsModel(
        userName: _orFallback(user.displayName, fallback.userName),
        email: _orFallback(user.email, fallback.email),
        phoneNumber: fallback.phoneNumber,
        rating: fallback.rating,
        membershipName: fallback.membershipName,
        isPhoneVerified: fallback.isPhoneVerified,
      ).toEntity();
    } on AuthException catch (e) {
      if (e.statusCode == 401) rethrow;
      return fallback.toEntity();
    } catch (_) {
      return fallback.toEntity();
    }
  }

  String _orFallback(String? value, String fallback) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return fallback;
  }
}
