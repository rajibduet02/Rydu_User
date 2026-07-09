import '../repositories/support_repository.dart';

class SubmitEmailSupportUsecase {
  SubmitEmailSupportUsecase(this._repository);

  final SupportRepository _repository;

  Future<void> call({
    required String subject,
    required String category,
    required String message,
    String? attachmentPath,
  }) => _repository.submitEmailSupport(
    subject: subject,
    category: category,
    message: message,
    attachmentPath: attachmentPath,
  );
}
