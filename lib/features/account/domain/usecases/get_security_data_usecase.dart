import '../entities/security_data_entity.dart';
import '../repositories/security_repository.dart';

class GetSecurityDataUsecase {
  GetSecurityDataUsecase(this._repository);

  final SecurityRepository _repository;

  Future<SecurityDataEntity> call() => _repository.getSecurityData();
}
