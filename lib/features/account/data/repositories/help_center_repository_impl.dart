import '../../domain/entities/faqs_data_entity.dart';
import '../../domain/repositories/help_center_repository.dart';
import '../datasources/help_center_local_datasource.dart';

class HelpCenterRepositoryImpl implements HelpCenterRepository {
  HelpCenterRepositoryImpl(this._local);

  final HelpCenterLocalDatasource _local;

  @override
  Future<FaqsDataEntity> getFaqs() async {
    final model = await _local.fetchFaqs();
    return model.toEntity();
  }
}
