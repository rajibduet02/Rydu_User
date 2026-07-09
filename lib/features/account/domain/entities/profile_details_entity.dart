class ProfileDetailsEntity {
  const ProfileDetailsEntity({
    required this.userName,
    required this.phoneNumber,
    required this.email,
    required this.rating,
    required this.membershipName,
    required this.isPhoneVerified,
  });

  final String userName;
  final String phoneNumber;
  final String email;
  final String rating;
  final String membershipName;
  final bool isPhoneVerified;
}
