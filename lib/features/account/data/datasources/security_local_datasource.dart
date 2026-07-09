import '../models/emergency_contact_model.dart';
import '../models/safety_center_data_model.dart';
import '../models/security_data_model.dart';

abstract interface class SecurityLocalDatasource {
  Future<SecurityDataModel> fetchSecurityData();
  Future<SafetyCenterDataModel> fetchSafetyCenterData();
  Future<SafetyCenterDataModel> enableTripSharing();
  Future<List<EmergencyContactModel>> fetchEmergencyContacts();
}

class SecurityLocalDatasourceImpl implements SecurityLocalDatasource {
  @override
  Future<SecurityDataModel> fetchSecurityData() async {
    // TODO: Load security status and MFA settings from backend API.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const SecurityDataModel(securityStatus: 'STABLE', hasThreats: false);
  }

  @override
  Future<SafetyCenterDataModel> fetchSafetyCenterData() async {
    // TODO: Load safety checklist, contacts, and trip-sharing flag from API.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return SafetyCenterDataModel.fromSeed();
  }

  @override
  Future<SafetyCenterDataModel> enableTripSharing() async {
    // TODO: PATCH user preference for live trip sharing when backend exists.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return SafetyCenterDataModel.fromSeed(isTripSharingEnabled: true);
  }

  @override
  Future<List<EmergencyContactModel>> fetchEmergencyContacts() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return EmergencyContactModel.seed();
  }
}
