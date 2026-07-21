import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/location/location_service.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/fare_estimate_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/pickup_spot_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_booking_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_destination_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_option_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/domain/repositories/ride_booking_repository.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';

class _FakeLocationService extends LocationService {
  _FakeLocationService({this.permission = AppLocationPermissionStatus.granted});

  bool serviceEnabled = true;
  AppLocationPermissionStatus permission;
  AppPosition? position = const AppPosition(latitude: 23.75, longitude: 90.38);

  @override
  Future<bool> isServiceEnabled() async => serviceEnabled;

  @override
  Future<AppLocationPermissionStatus> checkPermission() async => permission;

  @override
  Future<AppLocationPermissionStatus> requestPermission() async => permission;

  @override
  Future<AppPosition?> getCurrentPosition({
    Duration timeLimit = const Duration(seconds: 15),
  }) async => position;

  @override
  Future<bool> openAppSettings() async => true;
}

class _FakeRideBookingRepository implements RideBookingRepository {
  PlaceEntity? reverseGeocodeResult = const PlaceEntity(
    placeId: '',
    label: 'Road 2, Dhanmondi',
    address: 'Dhanmondi, Dhaka',
    latitude: 23.75,
    longitude: 90.38,
  );
  bool throwOnReverseGeocode = false;
  PlaceEntity? placeDetailsResult;
  int previewRouteCalls = 0;

  @override
  String getDefaultPickupLocation() => '';

  @override
  Future<List<RideDestinationEntity>> getSuggestedLocations() async => [];

  @override
  Future<RideDestinationEntity?> findDestinationById(String id) async => null;

  @override
  Future<List<RideOptionEntity>> getRideOptions() async => [];

  @override
  Future<RideOptionEntity?> findRideOptionById(String id) async => null;

  @override
  Future<List<PickupSpotEntity>> getPickupSpots() async => [];

  @override
  String pickupSpotLabel(int index) => '';

  @override
  Future<FareEstimateEntity> estimateFare({
    required String rideType,
    required String optionId,
  }) async => throw UnimplementedError();

  @override
  Future<void> confirmPickup({required RideBookingEntity booking}) async {}

  @override
  Future<String> createRideRequest({
    required RideBookingEntity booking,
  }) async => 'id';

  @override
  Future<String> createRideDraft() async => 'draft';

  @override
  Future<void> confirmRide({required String rideDraftId}) async {}

  @override
  Future<PlaceEntity?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    if (throwOnReverseGeocode) {
      throw Exception('reverse geocode failed');
    }
    return reverseGeocodeResult;
  }

  @override
  Future<List<PlacePredictionEntity>> autocomplete({
    required String input,
    double? lat,
    double? lng,
    String? city,
    String? country,
    String? sessionToken,
    dynamic cancelToken,
  }) async => [];

  @override
  Future<PlaceEntity?> placeDetails({
    required String placeId,
    String? sessionToken,
  }) async => placeDetailsResult;

  @override
  Future<List<PlacePredictionEntity>> placeSuggestions({
    double? lat,
    double? lng,
  }) async => [];

  @override
  Future<List<PickupSpotEntity>> fetchPickupSpots({
    required double lat,
    required double lng,
    String? address,
  }) async => [];

  @override
  Future<List<NearbyDriverEntity>> nearbyDrivers({
    required double lat,
    required double lng,
    required String serviceCategoryId,
    double? radiusKm,
  }) async => [];

  static const _sampleRoute = RoutePreviewEntity(
    distanceMeters: 5000,
    distanceKm: 5,
    durationSeconds: 900,
    durationMin: 15,
    encodedPolyline: '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    routeBounds: RouteBoundsEntity(
      northeast: GeoPointEntity(latitude: 23.9, longitude: 90.5),
      southwest: GeoPointEntity(latitude: 23.7, longitude: 90.3),
    ),
  );

  @override
  Future<RoutePreviewEntity> previewRoute({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) async {
    previewRouteCalls++;
    return _sampleRoute;
  }

  @override
  Future<BookingQuoteEntity> quoteBooking({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) async {
    // Empty quotes stop navigation before go_router is needed in unit tests.
    return const BookingQuoteEntity(route: _sampleRoute, quotes: []);
  }

  @override
  Future<List<PaymentMethodEntity>> paymentMethods() async => [];

  @override
  Future<BookingEntity> createBooking({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    required String idempotencyKey,
  }) async => throw UnimplementedError();

  @override
  Future<BookingEntity?> activeBooking() async => null;

  @override
  Future<BookingEntity?> bookingById(String bookingId) async => null;

  @override
  Future<BookingEntity?> cancelBooking(
    String bookingId, {
    String? reason,
    String? idempotencyKey,
  }) async => null;
}

ProviderContainer _container({
  required _FakeLocationService location,
  required _FakeRideBookingRepository repo,
}) {
  return ProviderContainer(
    overrides: [
      locationServiceProvider.overrideWithValue(location),
      rideBookingRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RideBookingController pickup bootstrap', () {
    test('bootstrap resolves GPS pickup without placeId', () async {
      final location = _FakeLocationService();
      final repo = _FakeRideBookingRepository();
      final container = _container(location: location, repo: repo);
      addTearDown(container.dispose);

      final controller = container.read(rideBookingControllerProvider.notifier);
      await controller.bootstrapCurrentLocation(userInitiated: false);

      final state = container.read(rideBookingControllerProvider);
      expect(state.hasResolvedPickup, isTrue);
      expect(state.pickupSource, PickupSource.currentLocation);
      expect(state.pickupPlace?.placeId, isEmpty);
      expect(state.pickupLocation, 'Road 2, Dhanmondi');
      expect(state.isPickupResolved, isTrue);
    });

    test('programmatic suppress keeps pickup resolved', () async {
      final location = _FakeLocationService();
      final repo = _FakeRideBookingRepository();
      final container = _container(location: location, repo: repo);
      addTearDown(container.dispose);

      final controller = container.read(rideBookingControllerProvider.notifier);
      await controller.bootstrapCurrentLocation(userInitiated: false);

      controller.suppressPickupTextInvalidation = true;
      controller.updatePickupLocation('Road 2, Dhanmondi');
      controller.suppressPickupTextInvalidation = false;

      final state = container.read(rideBookingControllerProvider);
      expect(state.hasResolvedPickup, isTrue);
      expect(state.pickupPlace?.latitude, 23.75);
    });

    test('user editing pickup invalidates coordinates', () async {
      final location = _FakeLocationService();
      final repo = _FakeRideBookingRepository();
      final container = _container(location: location, repo: repo);
      addTearDown(container.dispose);

      final controller = container.read(rideBookingControllerProvider.notifier);
      await controller.bootstrapCurrentLocation(userInitiated: false);
      controller.updatePickupLocation('Banani typed differently');

      final state = container.read(rideBookingControllerProvider);
      expect(state.hasResolvedPickup, isFalse);
      expect(state.pickupPlace, isNull);
    });

    test(
      'use current location preserves destination and can preview',
      () async {
        final location = _FakeLocationService();
        final repo = _FakeRideBookingRepository();
        final container = _container(location: location, repo: repo);
        addTearDown(container.dispose);

        final controller = container.read(
          rideBookingControllerProvider.notifier,
        );
        await controller.bootstrapCurrentLocation(userInitiated: false);

        repo.placeDetailsResult = const PlaceEntity(
          placeId: 'd1',
          label: 'Mirpur',
          address: 'Dhaka',
          latitude: 23.8,
          longitude: 90.4,
        );
        controller.setActiveSearchField(ActiveSearchField.destination);
        await controller.selectPrediction(
          const PlacePredictionEntity(
            placeId: 'd1',
            primaryText: 'Mirpur',
            secondaryText: 'Dhaka',
          ),
        );

        var state = container.read(rideBookingControllerProvider);
        expect(state.hasResolvedDestination, isTrue);
        final destLabel = state.destinationQuery;
        final previewCallsAfterDestination = repo.previewRouteCalls;
        expect(previewCallsAfterDestination, greaterThan(0));

        location.position = const AppPosition(
          latitude: 23.751,
          longitude: 90.381,
        );
        repo.reverseGeocodeResult = const PlaceEntity(
          placeId: '',
          label: 'Fresh GPS',
          address: 'Dhaka',
          latitude: 23.751,
          longitude: 90.381,
        );
        await controller.useCurrentLocation();

        state = container.read(rideBookingControllerProvider);
        expect(state.hasResolvedPickup, isTrue);
        expect(state.destinationQuery, destLabel);
        expect(state.hasResolvedDestination, isTrue);
        expect(
          repo.previewRouteCalls,
          greaterThan(previewCallsAfterDestination),
        );
      },
    );

    test('manual pickup selection resolves pickup', () async {
      final location = _FakeLocationService(
        permission: AppLocationPermissionStatus.denied,
      );
      final repo = _FakeRideBookingRepository();
      repo.placeDetailsResult = const PlaceEntity(
        placeId: 'p1',
        label: 'Banasree',
        address: 'Dhaka',
        latitude: 23.76,
        longitude: 90.42,
      );
      final container = _container(location: location, repo: repo);
      addTearDown(container.dispose);

      final controller = container.read(rideBookingControllerProvider.notifier);
      await controller.bootstrapCurrentLocation(userInitiated: false);
      expect(
        container.read(rideBookingControllerProvider).hasResolvedPickup,
        isFalse,
      );

      controller.setActiveSearchField(ActiveSearchField.pickup);
      await controller.selectPrediction(
        const PlacePredictionEntity(
          placeId: 'p1',
          primaryText: 'Banasree',
          secondaryText: 'Dhaka',
        ),
      );

      final state = container.read(rideBookingControllerProvider);
      expect(state.hasResolvedPickup, isTrue);
      expect(state.pickupSource, PickupSource.manualSelection);
      expect(state.pickupLocation, 'Banasree');
    });

    test(
      'reverse geocode failure still resolves with coordinate label',
      () async {
        final location = _FakeLocationService();
        final repo = _FakeRideBookingRepository()..throwOnReverseGeocode = true;
        final container = _container(location: location, repo: repo);
        addTearDown(container.dispose);

        final controller = container.read(
          rideBookingControllerProvider.notifier,
        );
        await controller.bootstrapCurrentLocation(userInitiated: false);

        final state = container.read(rideBookingControllerProvider);
        expect(state.hasResolvedPickup, isTrue);
        expect(state.pickupPlace?.placeId, isEmpty);
        expect(state.pickupPlace?.hasCoordinates, isTrue);
      },
    );

    test('continueToRideSelection shows pickup-specific message', () async {
      final location = _FakeLocationService(
        permission: AppLocationPermissionStatus.denied,
      );
      final repo = _FakeRideBookingRepository();
      repo.placeDetailsResult = const PlaceEntity(
        placeId: 'd1',
        label: 'Mirpur',
        address: 'Dhaka',
        latitude: 23.8,
        longitude: 90.4,
      );
      final container = _container(location: location, repo: repo);
      addTearDown(container.dispose);

      final controller = container.read(rideBookingControllerProvider.notifier);
      controller.setActiveSearchField(ActiveSearchField.destination);
      await controller.selectPrediction(
        const PlacePredictionEntity(
          placeId: 'd1',
          primaryText: 'Mirpur',
          secondaryText: 'Dhaka',
        ),
      );

      controller.continueToRideSelection();
      final state = container.read(rideBookingControllerProvider);
      expect(state.errorMessage, 'Please select a pickup location.');
    });
  });
}
