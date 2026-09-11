import 'dart:io';

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
  PlaceEntity? reverseGeocodeResult;
  PlaceEntity? placeDetailsResult;
  String? lastAutocompleteCountry;
  String? lastAutocompleteInput;
  int autocompleteCalls = 0;

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
  }) async => reverseGeocodeResult;

  @override
  Future<List<PlacePredictionEntity>> autocomplete({
    required String input,
    double? lat,
    double? lng,
    String? city,
    String? country,
    String? sessionToken,
    dynamic cancelToken,
  }) async {
    autocompleteCalls++;
    lastAutocompleteInput = input;
    lastAutocompleteCountry = country;
    return const [];
  }

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
  }) async => _sampleRoute;

  @override
  Future<BookingQuoteEntity> quoteBooking({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) async => const BookingQuoteEntity(route: _sampleRoute, quotes: []);

  @override
  Future<List<PaymentMethodEntity>> paymentMethods() async => [];

  @override
  Future<PaymentConfigEntity> paymentConfig() async =>
      const PaymentConfigEntity(stripeEnabled: false, cardEnabled: false);

  @override
  Future<CreateBookingResult> createBooking({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    required String idempotencyKey,
  }) async => throw UnimplementedError();

  @override
  Future<BookingPaymentEntity> bookingPayment(String bookingId) async =>
      throw UnimplementedError();

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

  @override
  Future<RecordingConsentResult> submitRecordingConsent({
    required String bookingId,
    required bool consent,
  }) async => RecordingConsentResult(consent: consent);
}

const _dhakaGps = PlaceEntity(
  placeId: '',
  label: 'Road 2, Dhanmondi',
  address: 'Dhanmondi, Dhaka',
  latitude: 23.75,
  longitude: 90.38,
  country: 'Bangladesh',
  countryCode: 'BD',
);

const _nycGps = PlaceEntity(
  placeId: '',
  label: 'Times Square',
  address: 'New York, NY',
  latitude: 40.758,
  longitude: -73.9855,
  country: 'United States',
  countryCode: 'US',
);

const _nycManual = PlaceEntity(
  placeId: 'ChIJ-nyc',
  label: 'Times Square',
  address: 'New York, NY',
  latitude: 40.758,
  longitude: -73.9855,
  country: 'United States',
  countryCode: 'US',
);

const _dhakaManual = PlaceEntity(
  placeId: 'ChIJ-dacca',
  label: 'Mirpur',
  address: 'Dhaka, Bangladesh',
  latitude: 23.81,
  longitude: 90.36,
  country: 'Bangladesh',
  countryCode: 'BD',
);

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

  group('dynamic Places autocomplete country', () {
    test('A. reverse geocode BD → pickup autocomplete sends BD', () async {
      final repo = _FakeRideBookingRepository()..reverseGeocodeResult = _dhakaGps;
      final container = _container(
        location: _FakeLocationService(),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);

      await controller.bootstrapCurrentLocation(userInitiated: false);
      await controller.debugRunAutocomplete(
        'Mirpur',
        ActiveSearchField.pickup,
      );

      expect(controller.debugResolvedAutocompleteCountry(), 'BD');
      expect(repo.lastAutocompleteCountry, 'BD');
    });

    test('B. reverse geocode US → pickup autocomplete sends US', () async {
      final location = _FakeLocationService()
        ..position = const AppPosition(latitude: 40.758, longitude: -73.9855);
      final repo = _FakeRideBookingRepository()..reverseGeocodeResult = _nycGps;
      final container = _container(location: location, repo: repo);
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);

      await controller.bootstrapCurrentLocation(userInitiated: false);
      await controller.debugRunAutocomplete(
        'Central Park',
        ActiveSearchField.pickup,
      );

      expect(controller.debugResolvedAutocompleteCountry(), 'US');
      expect(repo.lastAutocompleteCountry, 'US');
    });

    test('C. selected pickup BD → destination autocomplete sends BD', () async {
      final repo = _FakeRideBookingRepository()
        ..placeDetailsResult = _dhakaManual;
      final container = _container(
        location: _FakeLocationService(
          permission: AppLocationPermissionStatus.denied,
        ),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);

      controller.setActiveSearchField(ActiveSearchField.pickup);
      await controller.selectPrediction(
        const PlacePredictionEntity(
          placeId: 'ChIJ-dacca',
          primaryText: 'Mirpur',
          secondaryText: 'Dhaka',
        ),
      );
      await controller.debugRunAutocomplete(
        'Gulshan',
        ActiveSearchField.destination,
      );

      expect(controller.debugResolvedAutocompleteCountry(), 'BD');
      expect(repo.lastAutocompleteCountry, 'BD');
    });

    test('D. selected pickup US → destination autocomplete sends US', () async {
      final repo = _FakeRideBookingRepository()..placeDetailsResult = _nycManual;
      final container = _container(
        location: _FakeLocationService(
          permission: AppLocationPermissionStatus.denied,
        ),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);

      controller.setActiveSearchField(ActiveSearchField.pickup);
      await controller.selectPrediction(
        const PlacePredictionEntity(
          placeId: 'ChIJ-nyc',
          primaryText: 'Times Square',
          secondaryText: 'New York',
        ),
      );
      await controller.debugRunAutocomplete(
        'JFK',
        ActiveSearchField.destination,
      );

      expect(controller.debugResolvedAutocompleteCountry(), 'US');
      expect(repo.lastAutocompleteCountry, 'US');
    });

    test('E. GPS BD then manual pickup US → destination sends US', () async {
      final repo = _FakeRideBookingRepository()
        ..reverseGeocodeResult = _dhakaGps
        ..placeDetailsResult = _nycManual;
      final container = _container(
        location: _FakeLocationService(),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);

      await controller.bootstrapCurrentLocation(userInitiated: false);
      expect(controller.debugResolvedAutocompleteCountry(), 'BD');

      controller.setActiveSearchField(ActiveSearchField.pickup);
      await controller.selectPrediction(
        const PlacePredictionEntity(
          placeId: 'ChIJ-nyc',
          primaryText: 'Times Square',
          secondaryText: 'New York',
        ),
      );
      await controller.debugRunAutocomplete(
        'Brooklyn',
        ActiveSearchField.destination,
      );

      expect(
        container.read(rideBookingControllerProvider).pickupPlace?.countryCode,
        'US',
      );
      expect(controller.debugResolvedAutocompleteCountry(), 'US');
      expect(repo.lastAutocompleteCountry, 'US');
    });

    test('F. GPS US then manual pickup BD → destination sends BD', () async {
      final location = _FakeLocationService()
        ..position = const AppPosition(latitude: 40.758, longitude: -73.9855);
      final repo = _FakeRideBookingRepository()
        ..reverseGeocodeResult = _nycGps
        ..placeDetailsResult = _dhakaManual;
      final container = _container(location: location, repo: repo);
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);

      await controller.bootstrapCurrentLocation(userInitiated: false);
      expect(controller.debugResolvedAutocompleteCountry(), 'US');

      controller.setActiveSearchField(ActiveSearchField.pickup);
      await controller.selectPrediction(
        const PlacePredictionEntity(
          placeId: 'ChIJ-dacca',
          primaryText: 'Mirpur',
          secondaryText: 'Dhaka',
        ),
      );
      await controller.debugRunAutocomplete(
        'Gulshan',
        ActiveSearchField.destination,
      );

      expect(controller.debugResolvedAutocompleteCountry(), 'BD');
      expect(repo.lastAutocompleteCountry, 'BD');
    });

    test('G. lowercase countryCode bd → normalized BD', () async {
      final repo = _FakeRideBookingRepository();
      final container = _container(
        location: _FakeLocationService(),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);
      controller.debugSeedState(
        const RideBookingState(
          pickupPlace: PlaceEntity(
            placeId: 'p',
            label: 'Mirpur',
            address: 'Dhaka',
            latitude: 23.81,
            longitude: 90.36,
            countryCode: 'bd',
          ),
          pickupSource: PickupSource.manualSelection,
          isPickupResolved: true,
        ),
      );

      await controller.debugRunAutocomplete(
        'Banani',
        ActiveSearchField.pickup,
      );

      expect(controller.debugResolvedAutocompleteCountry(), 'BD');
      expect(repo.lastAutocompleteCountry, 'BD');
    });

    test('H. lowercase countryCode us → normalized US', () async {
      final repo = _FakeRideBookingRepository();
      final container = _container(
        location: _FakeLocationService(),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);
      controller.debugSeedState(
        const RideBookingState(
          pickupPlace: PlaceEntity(
            placeId: 'p',
            label: 'SoHo',
            address: 'New York',
            latitude: 40.72,
            longitude: -74.0,
            countryCode: 'us',
          ),
          pickupSource: PickupSource.manualSelection,
          isPickupResolved: true,
        ),
      );

      await controller.debugRunAutocomplete(
        'Brooklyn',
        ActiveSearchField.destination,
      );

      expect(controller.debugResolvedAutocompleteCountry(), 'US');
      expect(repo.lastAutocompleteCountry, 'US');
    });

    test('I. missing countryCode → autocomplete omits country', () async {
      final repo = _FakeRideBookingRepository()
        ..reverseGeocodeResult = const PlaceEntity(
          placeId: '',
          label: 'Somewhere',
          address: 'Unknown',
          latitude: 23.75,
          longitude: 90.38,
        );
      final container = _container(
        location: _FakeLocationService(),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);

      await controller.bootstrapCurrentLocation(userInitiated: false);
      await controller.debugRunAutocomplete(
        'Mirpur',
        ActiveSearchField.pickup,
      );

      expect(controller.debugResolvedAutocompleteCountry(), isNull);
      expect(repo.lastAutocompleteCountry, isNull);
    });

    test('J. invalid countryCode → autocomplete omits country', () async {
      final repo = _FakeRideBookingRepository();
      final container = _container(
        location: _FakeLocationService(),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);
      controller.debugSeedState(
        const RideBookingState(
          pickupPlace: PlaceEntity(
            placeId: 'p',
            label: 'Mirpur',
            address: 'Dhaka',
            latitude: 23.81,
            longitude: 90.36,
            country: 'Bangladesh',
            countryCode: 'Bangladesh',
          ),
          pickupSource: PickupSource.manualSelection,
          isPickupResolved: true,
        ),
      );

      await controller.debugRunAutocomplete(
        'Gulshan',
        ActiveSearchField.destination,
      );

      expect(controller.debugResolvedAutocompleteCountry(), isNull);
      expect(repo.lastAutocompleteCountry, isNull);
    });

    test(
      'K/L. _runAutocomplete has no hardcoded BD or US country literal',
      () {
        final source = File(
          'lib/features/ride_booking/presentation/providers/ride_booking_controller.dart',
        ).readAsStringSync();
        final start = source.indexOf('Future<void> _runAutocomplete');
        expect(start, greaterThan(0));
        final next = source.indexOf(
          'Future<void> selectDestination',
          start,
        );
        final body = source.substring(start, next);
        expect(body.contains("country: 'BD'"), isFalse);
        expect(body.contains('country: "BD"'), isFalse);
        expect(body.contains("country: 'US'"), isFalse);
        expect(body.contains('country: "US"'), isFalse);
        expect(body.contains('country: country'), isTrue);
      },
    );

    test('typing pickup after GPS still uses reverse-geocode country', () async {
      final repo = _FakeRideBookingRepository()..reverseGeocodeResult = _dhakaGps;
      final container = _container(
        location: _FakeLocationService(),
        repo: repo,
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);

      await controller.bootstrapCurrentLocation(userInitiated: false);
      controller.updatePickupLocation('Banani typed differently');
      expect(
        container.read(rideBookingControllerProvider).pickupPlace,
        isNull,
      );

      await controller.debugRunAutocomplete(
        'Banani typed differently',
        ActiveSearchField.pickup,
      );

      expect(controller.debugResolvedAutocompleteCountry(), 'BD');
      expect(repo.lastAutocompleteCountry, 'BD');
    });
  });
}
