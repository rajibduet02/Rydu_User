import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  GetCurrentUserUsecase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() => _repository.getCurrentUser();
}
