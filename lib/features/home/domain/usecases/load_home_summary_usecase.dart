import '../entities/home_summary_entity.dart';
import '../repositories/home_repository.dart';

class LoadHomeSummaryUsecase {
  LoadHomeSummaryUsecase(this._repository);

  final HomeRepository _repository;

  Future<HomeSummaryEntity> call() => _repository.loadSummary();
}
