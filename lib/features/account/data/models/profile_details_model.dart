import '../../domain/entities/profile_details_entity.dart';

class ProfileDetailsModel extends ProfileDetailsEntity {
  const ProfileDetailsModel({
    required super.userName,
    required super.phoneNumber,
    required super.email,
    required super.rating,
    required super.membershipName,
    required super.isPhoneVerified,
  });

  ProfileDetailsEntity toEntity() => this;
}
