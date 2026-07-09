import '../repositories/support_repository.dart';

class InitiateSupportCallUsecase {
  InitiateSupportCallUsecase(this._repository);

  final SupportRepository _repository;

  Future<void> call() => _repository.initiateSupportCall();
}
