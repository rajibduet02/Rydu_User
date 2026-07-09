import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/activity_local_datasource.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../domain/usecases/load_activities_usecase.dart';

final activityLocalDatasourceProvider = Provider<ActivityLocalDatasource>((
  ref,
) {
  return ActivityLocalDatasourceImpl();
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(ref.watch(activityLocalDatasourceProvider));
});

final loadActivitiesUsecaseProvider = Provider<LoadActivitiesUsecase>((ref) {
  return LoadActivitiesUsecase(ref.watch(activityRepositoryProvider));
});
