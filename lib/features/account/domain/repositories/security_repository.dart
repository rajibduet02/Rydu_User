import '../entities/emergency_contact_entity.dart';
import '../entities/safety_center_data_entity.dart';
import '../entities/security_data_entity.dart';

abstract interface class SecurityRepository {
  Future<SecurityDataEntity> getSecurityData();
  Future<SafetyCenterDataEntity> getSafetyCenterData();
  Future<SafetyCenterDataEntity> enableTripSharing();
  Future<List<EmergencyContactEntity>> getEmergencyContacts();
}
