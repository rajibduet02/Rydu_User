import '../repositories/auth_repository.dart';

class SendOtpUsecase {
  SendOtpUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String phone}) {
    return _repository.sendOtp(phone: phone);
  }
}
