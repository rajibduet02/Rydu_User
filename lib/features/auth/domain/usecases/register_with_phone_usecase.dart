import '../repositories/auth_repository.dart';

class RegisterWithPhoneUsecase {
  RegisterWithPhoneUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String fullName,
    required String fullPhone,
    required String password,
  }) {
    return _repository.registerWithPhone(
      fullName: fullName,
      fullPhone: fullPhone,
      password: password,
    );
  }
}
