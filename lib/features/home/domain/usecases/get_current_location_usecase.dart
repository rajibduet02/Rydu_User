import '../repositories/home_repository.dart';

class GetCurrentLocationUsecase {
  GetCurrentLocationUsecase(this._repository);

  final HomeRepository _repository;

  Future<String> call() => _repository.resolveCurrentLocationLabel();
}
