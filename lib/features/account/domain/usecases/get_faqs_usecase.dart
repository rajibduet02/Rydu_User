import '../entities/faqs_data_entity.dart';
import '../repositories/help_center_repository.dart';

class GetFaqsUsecase {
  GetFaqsUsecase(this._repository);

  final HelpCenterRepository _repository;

  Future<FaqsDataEntity> call() => _repository.getFaqs();
}
