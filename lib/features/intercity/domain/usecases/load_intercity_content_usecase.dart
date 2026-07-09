import '../entities/intercity_content_entity.dart';
import '../repositories/intercity_repository.dart';

class LoadIntercityContentUsecase {
  const LoadIntercityContentUsecase(this._repository);

  final IntercityRepository _repository;

  Future<IntercityContentEntity> call() => _repository.loadIntercityContent();
}
