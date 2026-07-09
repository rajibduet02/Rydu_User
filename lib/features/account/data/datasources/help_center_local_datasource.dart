import '../models/faqs_data_model.dart';

abstract interface class HelpCenterLocalDatasource {
  Future<FaqsDataModel> fetchFaqs();
}

class HelpCenterLocalDatasourceImpl implements HelpCenterLocalDatasource {
  @override
  Future<FaqsDataModel> fetchFaqs() async {
    // TODO: Load FAQs from CMS / support API when backend is ready.
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return FaqsDataModel.fromSeed();
  }
}
