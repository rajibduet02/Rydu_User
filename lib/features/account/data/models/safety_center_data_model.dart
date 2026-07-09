import '../../domain/entities/safety_center_data_entity.dart';

class SafetyCenterDataModel extends SafetyCenterDataEntity {
  const SafetyCenterDataModel({
    required super.configuredFeaturesCount,
    required super.totalFeaturesCount,
    required super.emergencyContactsCount,
    required super.trustedContactsCount,
    required super.isTripSharingEnabled,
  });

  factory SafetyCenterDataModel.fromSeed({bool isTripSharingEnabled = false}) {
    return SafetyCenterDataModel(
      configuredFeaturesCount: 1,
      totalFeaturesCount: 5,
      emergencyContactsCount: 1,
      trustedContactsCount: 0,
      isTripSharingEnabled: isTripSharingEnabled,
    );
  }

  SafetyCenterDataEntity toEntity() => this;
}
