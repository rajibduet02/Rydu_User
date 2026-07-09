import '../../domain/entities/emergency_contact_entity.dart';

class EmergencyContactModel extends EmergencyContactEntity {
  const EmergencyContactModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.phoneNumber,
  });

  static List<EmergencyContactModel> seed() => const [
    EmergencyContactModel(
      id: 'police',
      title: 'Police Dispatch',
      subtitle: 'Local Authorities',
      phoneNumber: '+1-911',
    ),
    EmergencyContactModel(
      id: 'roadside',
      title: 'Roadside Assistance',
      subtitle: '24/7 Breakdown Support',
      phoneNumber: '+1-800-555-0199',
    ),
  ];

  EmergencyContactEntity toEntity() => this;
}
