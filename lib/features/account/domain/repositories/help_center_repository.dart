import '../entities/faqs_data_entity.dart';

abstract interface class HelpCenterRepository {
  Future<FaqsDataEntity> getFaqs();
}
