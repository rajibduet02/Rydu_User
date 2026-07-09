import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/home_local_datasource.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/load_home_summary_usecase.dart';

final homeRemoteDatasourceProvider = Provider<HomeRemoteDatasource>((ref) {
  return HomeRemoteDatasourceImpl();
});

final homeLocalDatasourceProvider = Provider<HomeLocalDatasource>((ref) {
  return HomeLocalDatasourceImpl();
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(
    ref.watch(homeRemoteDatasourceProvider),
    ref.watch(homeLocalDatasourceProvider),
  );
});

final loadHomeSummaryUsecaseProvider = Provider<LoadHomeSummaryUsecase>((ref) {
  return LoadHomeSummaryUsecase(ref.watch(homeRepositoryProvider));
});

final getCurrentLocationUsecaseProvider = Provider<GetCurrentLocationUsecase>((
  ref,
) {
  return GetCurrentLocationUsecase(ref.watch(homeRepositoryProvider));
});
