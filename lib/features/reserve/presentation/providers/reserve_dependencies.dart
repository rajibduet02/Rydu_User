import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/reserve_local_datasource.dart';
import '../../data/repositories/reserve_repository_impl.dart';
import '../../domain/repositories/reserve_repository.dart';
import '../../domain/usecases/start_reserve_ride_usecase.dart';

final reserveLocalDatasourceProvider = Provider<ReserveLocalDatasource>((ref) {
  return ReserveLocalDatasourceImpl();
});

final reserveRepositoryProvider = Provider<ReserveRepository>((ref) {
  return ReserveRepositoryImpl(ref.watch(reserveLocalDatasourceProvider));
});

final startReserveRideUsecaseProvider = Provider<StartReserveRideUsecase>((
  ref,
) {
  return StartReserveRideUsecase(ref.watch(reserveRepositoryProvider));
});
