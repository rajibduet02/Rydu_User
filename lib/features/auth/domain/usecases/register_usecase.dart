import '../repositories/auth_repository.dart';

class RegisterUsecase {
  RegisterUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
