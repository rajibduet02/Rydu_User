class SafetyCenterDataEntity {
  const SafetyCenterDataEntity({
    required this.configuredFeaturesCount,
    required this.totalFeaturesCount,
    required this.emergencyContactsCount,
    required this.trustedContactsCount,
    required this.isTripSharingEnabled,
  });

  final int configuredFeaturesCount;
  final int totalFeaturesCount;
  final int emergencyContactsCount;
  final int trustedContactsCount;
  final bool isTripSharingEnabled;
}
