import '../constants/profile_demo_data.dart';
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
      userName: ProfileDemoData.userName,
      phoneNumber: ProfileDemoData.phoneNumber,
      email: ProfileDemoData.email,
      rating: ProfileDemoData.rating,
      membershipName: ProfileDemoData.membershipName,
      isPhoneVerified: ProfileDemoData.isPhoneVerified,
    );
  }
}
