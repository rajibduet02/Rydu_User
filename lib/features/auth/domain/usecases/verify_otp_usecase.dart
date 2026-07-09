import '../repositories/auth_repository.dart';

class VerifyOtpUsecase {
  VerifyOtpUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String phone, required String code}) {
    return _repository.verifyOtp(phone: phone, code: code);
  }
}
