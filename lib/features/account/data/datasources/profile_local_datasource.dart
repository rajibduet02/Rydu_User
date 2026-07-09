import '../models/profile_details_model.dart';

abstract interface class ProfileLocalDatasource {
  Future<ProfileDetailsModel> fetchProfileDetails();
}

class ProfileLocalDatasourceImpl implements ProfileLocalDatasource {
  @override
  Future<ProfileDetailsModel> fetchProfileDetails() async {
    // TODO: Load user profile from API when backend is ready.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const ProfileDetailsModel(
      userName: 'Afshara Tasnim',
      phoneNumber: '+8801724536187',
      email: 'afsharatasnim@example.com',
      rating: '5.0',
      membershipName: 'RYD U ONE MEMBER',
      isPhoneVerified: true,
    );
  }
}
