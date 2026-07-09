import '../entities/emergency_contact_entity.dart';
import '../repositories/security_repository.dart';

class GetEmergencyContactsUsecase {
  GetEmergencyContactsUsecase(this._repository);

  final SecurityRepository _repository;

  Future<List<EmergencyContactEntity>> call() =>
      _repository.getEmergencyContacts();
}
