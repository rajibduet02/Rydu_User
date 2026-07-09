import '../repositories/auth_repository.dart';

class RestoreSessionUsecase {
  RestoreSessionUsecase(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.hasValidSession();
}
