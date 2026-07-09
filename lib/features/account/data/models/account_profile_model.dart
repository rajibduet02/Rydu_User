import '../../domain/entities/account_profile_entity.dart';

class AccountProfileModel {
  const AccountProfileModel({
    required this.userName,
    required this.membershipName,
    required this.rating,
    required this.rideCount,
    required this.walletBalance,
    required this.hasUnreadInbox,
    required this.savedPlacesCount,
    required this.appVersion,
  });

  final String userName;
  final String membershipName;
  final String rating;
  final int rideCount;
  final String walletBalance;
  final bool hasUnreadInbox;
  final int savedPlacesCount;
  final String appVersion;

  AccountProfileEntity toEntity() {
    return AccountProfileEntity(
      userName: userName,
      membershipName: membershipName,
      rating: rating,
      rideCount: rideCount,
      walletBalance: walletBalance,
      hasUnreadInbox: hasUnreadInbox,
      savedPlacesCount: savedPlacesCount,
      appVersion: appVersion,
    );
  }
}
