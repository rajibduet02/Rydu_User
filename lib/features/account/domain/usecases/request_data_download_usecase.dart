import '../repositories/privacy_repository.dart';

class RequestDataDownloadUsecase {
  RequestDataDownloadUsecase(this._repository);

  final PrivacyRepository _repository;

  Future<void> call() => _repository.requestDataDownload();
}
