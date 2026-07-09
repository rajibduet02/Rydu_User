import '../repositories/auth_repository.dart';

class RequestPasswordResetUsecase {
  RequestPasswordResetUsecase(this._repository);

  final AuthRepository _repository;

  Future<String> call({required String email}) {
    return _repository.requestPasswordReset(email: email);
  }
}
