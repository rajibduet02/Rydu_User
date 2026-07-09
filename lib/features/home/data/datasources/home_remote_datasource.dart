import '../models/home_summary_model.dart';

abstract interface class HomeRemoteDatasource {
  Future<HomeSummaryModel> fetchSummary();
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  HomeRemoteDatasourceImpl();

  @override
  Future<HomeSummaryModel> fetchSummary() async => const HomeSummaryModel();
}
