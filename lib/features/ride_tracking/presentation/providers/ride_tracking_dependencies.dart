import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ride_tracking_local_datasource.dart';
import '../../data/datasources/ride_tracking_remote_datasource.dart';
import '../../data/repositories/ride_tracking_repository_impl.dart';
import '../../domain/repositories/ride_tracking_repository.dart';
import '../../domain/usecases/cancel_ride_usecase.dart';
import '../../domain/usecases/contact_driver_usecase.dart';
import '../../domain/usecases/get_driver_found_usecase.dart';
import '../../domain/usecases/share_trip_status_usecase.dart';
import '../../domain/usecases/start_finding_driver_usecase.dart';
import '../../domain/usecases/watch_active_ride_usecase.dart';

final rideTrackingLocalDatasourceProvider =
    Provider<RideTrackingLocalDatasource>((ref) {
      return RideTrackingLocalDatasourceImpl();
    });

final rideTrackingRemoteDatasourceProvider =
    Provider<RideTrackingRemoteDatasource>((ref) {
      return RideTrackingRemoteDatasourceImpl();
    });

final rideTrackingRepositoryProvider = Provider<RideTrackingRepository>((ref) {
  return RideTrackingRepositoryImpl(
    localDatasource: ref.watch(rideTrackingLocalDatasourceProvider),
    remoteDatasource: ref.watch(rideTrackingRemoteDatasourceProvider),
  );
});

final watchActiveRideUsecaseProvider = Provider<WatchActiveRideUsecase>((ref) {
  return WatchActiveRideUsecase(ref.watch(rideTrackingRepositoryProvider));
});

final startFindingDriverUsecaseProvider = Provider<StartFindingDriverUsecase>((
  ref,
) {
  return StartFindingDriverUsecase(ref.watch(rideTrackingRepositoryProvider));
});

final getDriverFoundUsecaseProvider = Provider<GetDriverFoundUsecase>((ref) {
  return GetDriverFoundUsecase(ref.watch(rideTrackingRepositoryProvider));
});

final cancelRideUsecaseProvider = Provider<CancelRideUsecase>((ref) {
  return CancelRideUsecase(ref.watch(rideTrackingRepositoryProvider));
});

final shareTripStatusUsecaseProvider = Provider<ShareTripStatusUsecase>((ref) {
  return ShareTripStatusUsecase(ref.watch(rideTrackingRepositoryProvider));
});

final contactDriverUsecaseProvider = Provider<ContactDriverUsecase>((ref) {
  return ContactDriverUsecase(ref.watch(rideTrackingRepositoryProvider));
});
