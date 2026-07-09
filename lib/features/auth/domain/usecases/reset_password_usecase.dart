import '../repositories/auth_repository.dart';

class ResetPasswordUsecase {
  ResetPasswordUsecase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String newPassword,
    required String confirmPassword,
  }) {
    return _repository.resetPassword(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
