import '../../domain/entities/emergency_contact_entity.dart';
import '../../domain/entities/safety_center_data_entity.dart';
import '../../domain/entities/security_data_entity.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_local_datasource.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl(this._local);

  final SecurityLocalDatasource _local;

  @override
  Future<SecurityDataEntity> getSecurityData() async {
    final model = await _local.fetchSecurityData();
    return model.toEntity();
  }

  @override
  Future<SafetyCenterDataEntity> getSafetyCenterData() async {
    final model = await _local.fetchSafetyCenterData();
    return model.toEntity();
  }

  @override
  Future<SafetyCenterDataEntity> enableTripSharing() async {
    final model = await _local.enableTripSharing();
    return model.toEntity();
  }

  @override
  Future<List<EmergencyContactEntity>> getEmergencyContacts() async {
    final models = await _local.fetchEmergencyContacts();
    return models.map((m) => m.toEntity()).toList();
  }
}
