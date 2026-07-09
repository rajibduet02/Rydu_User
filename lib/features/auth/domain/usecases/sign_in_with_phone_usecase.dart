import '../repositories/auth_repository.dart';

class SignInWithPhoneUsecase {
  SignInWithPhoneUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String fullPhone, required String password}) {
    return _repository.signInWithPhone(
      fullPhone: fullPhone,
      password: password,
    );
  }
}
