import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/dio_provider.dart';
import '../../../../app/providers/storage_providers.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/network/passenger_socket_service.dart';
import '../../data/datasources/passenger_ride_remote_datasource.dart';
import '../../data/datasources/ride_booking_local_datasource.dart';
import '../../data/datasources/ride_booking_remote_datasource.dart';
import '../../data/repositories/ride_booking_repository_impl.dart';
import '../../domain/repositories/ride_booking_repository.dart';
import '../../domain/usecases/confirm_pickup_usecase.dart';
import '../../domain/usecases/confirm_ride_usecase.dart';
import '../../domain/usecases/create_ride_request_usecase.dart';
import '../../domain/usecases/estimate_fare_usecase.dart';
import '../../domain/usecases/get_default_pickup_location_usecase.dart';
import '../../domain/usecases/get_pickup_spot_label_usecase.dart';
import '../../domain/usecases/get_pickup_spots_usecase.dart';
import '../../domain/usecases/get_ride_options_usecase.dart';
import '../../domain/usecases/get_suggested_locations_usecase.dart';
import '../../domain/usecases/select_destination_usecase.dart';
import '../../domain/usecases/select_ride_option_usecase.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final passengerSocketServiceProvider = Provider<PassengerSocketService>((ref) {
  final service = PassengerSocketService(
    ref.watch(secureStorageServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final passengerRideRemoteDatasourceProvider =
    Provider<PassengerRideRemoteDatasource>((ref) {
      return PassengerRideRemoteDatasourceImpl(ref.watch(apiClientProvider));
    });

final rideBookingLocalDatasourceProvider = Provider<RideBookingLocalDatasource>(
  (ref) {
    return RideBookingLocalDatasourceImpl();
  },
);

final rideBookingRemoteDatasourceProvider =
    Provider<RideBookingRemoteDatasource>((ref) {
      return RideBookingRemoteDatasourceImpl();
    });

final rideBookingRepositoryProvider = Provider<RideBookingRepository>((ref) {
  return RideBookingRepositoryImpl(
    localDatasource: ref.watch(rideBookingLocalDatasourceProvider),
    remoteDatasource: ref.watch(rideBookingRemoteDatasourceProvider),
    passengerRemoteDatasource: ref.watch(passengerRideRemoteDatasourceProvider),
  );
});

final getSuggestedLocationsUsecaseProvider =
    Provider<GetSuggestedLocationsUsecase>((ref) {
      return GetSuggestedLocationsUsecase(
        ref.watch(rideBookingRepositoryProvider),
      );
    });

final selectDestinationUsecaseProvider = Provider<SelectDestinationUsecase>((
  ref,
) {
  return SelectDestinationUsecase(ref.watch(rideBookingRepositoryProvider));
});

final getRideOptionsUsecaseProvider = Provider<GetRideOptionsUsecase>((ref) {
  return GetRideOptionsUsecase(ref.watch(rideBookingRepositoryProvider));
});

final selectRideOptionUsecaseProvider = Provider<SelectRideOptionUsecase>((
  ref,
) {
  return SelectRideOptionUsecase(ref.watch(rideBookingRepositoryProvider));
});

final getPickupSpotsUsecaseProvider = Provider<GetPickupSpotsUsecase>((ref) {
  return GetPickupSpotsUsecase(ref.watch(rideBookingRepositoryProvider));
});

final getPickupSpotLabelUsecaseProvider = Provider<GetPickupSpotLabelUsecase>((
  ref,
) {
  return GetPickupSpotLabelUsecase(ref.watch(rideBookingRepositoryProvider));
});

final getDefaultPickupLocationUsecaseProvider =
    Provider<GetDefaultPickupLocationUsecase>((ref) {
      return GetDefaultPickupLocationUsecase(
        ref.watch(rideBookingRepositoryProvider),
      );
    });

final confirmPickupUsecaseProvider = Provider<ConfirmPickupUsecase>((ref) {
  return ConfirmPickupUsecase(ref.watch(rideBookingRepositoryProvider));
});

final createRideRequestUsecaseProvider = Provider<CreateRideRequestUsecase>((
  ref,
) {
  return CreateRideRequestUsecase(ref.watch(rideBookingRepositoryProvider));
});

final estimateFareUsecaseProvider = Provider<EstimateFareUsecase>((ref) {
  return EstimateFareUsecase(ref.watch(rideBookingRepositoryProvider));
});

final confirmRideUsecaseProvider = Provider<ConfirmRideUsecase>((ref) {
  return ConfirmRideUsecase(ref.watch(rideBookingRepositoryProvider));
});
