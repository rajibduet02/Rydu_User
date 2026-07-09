import '../entities/home_summary_entity.dart';

abstract interface class HomeRepository {
  Future<HomeSummaryEntity> loadSummary();

  Future<String> resolveCurrentLocationLabel();
}
