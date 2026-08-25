import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/dio_provider.dart';
import '../../data/datasources/ride_history_remote_datasource.dart';
import '../../data/repositories/ride_history_repository_impl.dart';
import '../../domain/repositories/ride_history_repository.dart';
import '../../domain/usecases/list_ride_history_usecase.dart';

final rideHistoryRemoteDatasourceProvider =
    Provider<RideHistoryRemoteDatasource>((ref) {
      return RideHistoryRemoteDatasourceImpl(ref.watch(apiClientProvider));
    });

final rideHistoryRepositoryProvider = Provider<RideHistoryRepository>((ref) {
  return RideHistoryRepositoryImpl(
    ref.watch(rideHistoryRemoteDatasourceProvider),
  );
});

final listRideHistoryUsecaseProvider = Provider<ListRideHistoryUsecase>((ref) {
  return ListRideHistoryUsecase(ref.watch(rideHistoryRepositoryProvider));
});

final getRideDetailsUsecaseProvider = Provider<GetRideDetailsUsecase>((ref) {
  return GetRideDetailsUsecase(ref.watch(rideHistoryRepositoryProvider));
});
