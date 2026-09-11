import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rydu_user/app/router/app_router.dart';
import 'package:rydu_user/app/router/route_names.dart';
import 'package:rydu_user/core/location/location_service.dart';
import 'package:rydu_user/core/network/passenger_api_error_mapper.dart';
import 'package:rydu_user/core/network/passenger_socket_service.dart';
import 'package:rydu_user/core/storage/secure_storage_service.dart';
import 'package:rydu_user/features/home/presentation/widgets/home_active_ride_card.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/fare_estimate_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/pickup_spot_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_booking_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_destination_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_option_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/domain/repositories/ride_booking_repository.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';

class _FakeRepo implements RideBookingRepository {
  BookingEntity? active;
  int cancelCalls = 0;
  String? lastCancelIdempotencyKey;
  Object? cancelError;

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
  }) async => null;

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
  }) async => null;

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

  @override
  Future<RoutePreviewEntity> previewRoute({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) async => throw UnimplementedError();

  @override
  Future<BookingQuoteEntity> quoteBooking({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) async => throw UnimplementedError();

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
  Future<BookingEntity?> activeBooking() async => active;

  @override
  Future<BookingEntity?> bookingById(String bookingId) async => active;

  @override
  Future<BookingEntity?> cancelBooking(
    String bookingId, {
    String? reason,
    String? idempotencyKey,
  }) async {
    cancelCalls++;
    lastCancelIdempotencyKey = idempotencyKey;
    if (cancelError != null) {
      final err = cancelError!;
      cancelError = null;
      // ignore: only_throw_errors
      throw err;
    }
    return BookingEntity(id: bookingId, status: 'cancelled');
  }

  @override
  Future<RecordingConsentResult> submitRecordingConsent({
    required String bookingId,
    required bool consent,
  }) async => RecordingConsentResult(
    consent: consent,
    consentStatus: consent ? 'granted' : 'denied',
    consented: consent,
    recordingConsentedAt: consent ? '2030-01-01T00:00:00.000Z' : null,
  );
}

BookingEntity _searchingBooking() => const BookingEntity(
  id: 'b-search',
  status: 'searching',
  pickupAddress: 'Dhanmondi',
  pickupLatitude: 23.75,
  pickupLongitude: 90.38,
  dropoffAddress: 'Mirpur',
  dropoffLatitude: 23.8,
  dropoffLongitude: 90.4,
  serviceName: 'CNG',
  serviceCategoryId: 'svc1',
  finalFare: 120,
  currency: 'BDT',
);

RideBookingState _seededSearchingState() {
  return const RideBookingState(
    bookingId: 'b-search',
    bookingStatus: 'searching',
    phase: RidePlanningPhase.bookingSearching,
    pickupLocation: 'Dhanmondi',
    destinationQuery: 'Mirpur',
    pickupPlace: PlaceEntity(
      placeId: '',
      label: 'Dhanmondi',
      address: 'Dhanmondi',
      latitude: 23.75,
      longitude: 90.38,
    ),
    dropoffPlace: PlaceEntity(
      placeId: 'd1',
      label: 'Mirpur',
      address: 'Mirpur',
      latitude: 23.8,
      longitude: 90.4,
    ),
    selectedVehicle: RideOptionEntity(
      id: 'svc1',
      name: 'CNG',
      category: 'recommended',
      time: '',
      description: '',
      price: 'BDT 120.00',
    ),
    selectedVehicleId: 'svc1',
    estimatedFare: 'BDT 120.00',
    isPickupResolved: true,
    pickupSource: PickupSource.currentLocation,
    socketStatus: ActiveRideSocketStatus.connected,
  );
}

ProviderContainer _container(_FakeRepo repo) {
  final goRouter = GoRouter(
    initialLocation: RouteNames.findingDriver,
    routes: [
      GoRoute(path: RouteNames.home, builder: (_, _) => const SizedBox()),
      GoRoute(
        path: RouteNames.findingDriver,
        builder: (_, _) => const SizedBox(),
      ),
      GoRoute(
        path: RouteNames.driverFound,
        builder: (_, _) => const SizedBox(),
      ),
      GoRoute(
        path: RouteNames.rideSelection,
        builder: (_, _) => const SizedBox(),
      ),
    ],
  );

  return ProviderContainer(
    overrides: [
      rideBookingRepositoryProvider.overrideWithValue(repo),
      locationServiceProvider.overrideWithValue(LocationService()),
      passengerSocketServiceProvider.overrideWithValue(
        PassengerSocketService(SecureStorageService()),
      ),
      goRouterProvider.overrideWithValue(goRouter),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Active booking UX state', () {
    test('1. searching booking is active without cancel', () {
      const state = RideBookingState(
        bookingId: 'b-search',
        bookingStatus: 'searching',
        phase: RidePlanningPhase.bookingSearching,
        socketStatus: ActiveRideSocketStatus.connected,
      );
      expect(state.hasActiveBooking, isTrue);
      expect(state.bookingId, 'b-search');
      expect(state.socketStatus, ActiveRideSocketStatus.connected);
      expect(state.canCancelBooking, isTrue);
    });

    test('2. home shows active searching card label', () {
      const state = RideBookingState(
        bookingId: 'b1',
        phase: RidePlanningPhase.bookingSearching,
        selectedVehicle: RideOptionEntity(
          id: 'svc1',
          name: 'CNG',
          category: 'recommended',
          time: '5 min',
          description: '',
          price: 'BDT 120.00',
        ),
        pickupLocation: 'Dhanmondi',
        dropoffPlace: PlaceEntity(
          placeId: 'd1',
          label: 'Mirpur',
          address: 'Dhaka',
          latitude: 23.8,
          longitude: 90.4,
        ),
      );
      expect(state.activeRideStatusLabel, 'Finding a driver…');
      expect(state.serviceNameLabel, 'CNG');
      expect(state.destinationLabel, 'Mirpur');
    });

    test('3. resume target for searching is Finding Driver path contract', () {
      const state = RideBookingState(
        bookingId: 'b1',
        phase: RidePlanningPhase.bookingSearching,
      );
      expect(state.isSearchingForDriver, isTrue);
      expect(state.isAssignedRidePhase, isFalse);
    });

    test('4. app restart restores searching booking entity', () {
      final booking = RidePlanningParsers.booking({
        'id': 'b1',
        'status': 'searching',
        'pickup': {'address': 'Pickup', 'latitude': 23.7, 'longitude': 90.3},
        'dropoff': {'address': 'Drop', 'latitude': 23.8, 'longitude': 90.4},
      });
      expect(booking, isNotNull);
      expect(booking!.isActive, isTrue);
      expect(
        ridePhaseFromBookingStatus(booking.status),
        RidePlanningPhase.bookingSearching,
      );
    });

    test('5. app restart restores accepted booking entity', () {
      final booking = RidePlanningParsers.booking({
        'id': 'b2',
        'status': 'accepted',
        'driver': {'id': 'd1', 'name': 'Driver'},
      });
      expect(booking!.isActive, isTrue);
      expect(
        ridePhaseFromBookingStatus(booking.status),
        RidePlanningPhase.driverAccepted,
      );
      expect(
        const RideBookingState(
          bookingId: 'b2',
          phase: RidePlanningPhase.driverAccepted,
        ).activeRideStatusLabel,
        'Driver is on the way',
      );
    });

    test('11. booking expired shows terminal copy', () {
      const state = RideBookingState(
        bookingId: 'b3',
        phase: RidePlanningPhase.expired,
      );
      expect(state.isTerminalRidePhase, isTrue);
      expect(state.hasActiveBooking, isFalse);
      expect(
        state.activeRideStatusLabel,
        'No drivers are available right now.',
      );
    });

    test('status labels for arrived and in progress', () {
      expect(
        const RideBookingState(
          phase: RidePlanningPhase.driverArrived,
        ).activeRideStatusLabel,
        'Driver has arrived',
      );
      expect(
        const RideBookingState(
          phase: RidePlanningPhase.rideInProgress,
        ).activeRideStatusLabel,
        'Ride in progress',
      );
    });
  });

  group('Cancel idempotency + minimize', () {
    test(
      '6/7. one cancel tap makes one API call and blocks double taps',
      () async {
        final repo = _FakeRepo()..active = _searchingBooking();
        final container = _container(repo);
        addTearDown(container.dispose);

        final c = container.read(rideBookingControllerProvider.notifier);
        c.debugSeedState(_seededSearchingState());

        final first = c.cancelActiveBooking();
        final second = c.cancelActiveBooking();
        final results = await Future.wait([first, second]);

        expect(repo.cancelCalls, 1);
        expect(results.where((ok) => ok).length, 1);
        expect(container.read(rideBookingControllerProvider).bookingId, isNull);
      },
    );

    test('8. idempotency key reused during retry', () async {
      final repo = _FakeRepo()..active = _searchingBooking();
      final container = _container(repo);
      addTearDown(container.dispose);

      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_seededSearchingState());

      repo.cancelError = const PassengerApiException(
        'Wait',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
      final failed = await c.cancelActiveBooking();
      expect(failed, isFalse);
      final key = container
          .read(rideBookingControllerProvider)
          .cancelIdempotencyKey;
      expect(key, isNotNull);
      expect(repo.lastCancelIdempotencyKey, key);
      expect(
        container.read(rideBookingControllerProvider).bookingId,
        isNotNull,
      );

      final ok = await c.cancelActiveBooking();
      expect(ok, isTrue);
      expect(repo.cancelCalls, 2);
      expect(repo.lastCancelIdempotencyKey, key);
    });

    test('9. 429 preserves active booking', () async {
      final repo = _FakeRepo()..active = _searchingBooking();
      final container = _container(repo);
      addTearDown(container.dispose);

      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_seededSearchingState());
      repo.cancelError = const PassengerApiException(
        'Too many requests',
        code: 'RATE_LIMITED',
        statusCode: 429,
        details: {'retryAfter': 30},
      );

      final ok = await c.cancelActiveBooking();
      expect(ok, isFalse);
      final state = container.read(rideBookingControllerProvider);
      expect(state.bookingId, 'b-search');
      expect(state.hasActiveBooking, isTrue);
      expect(state.errorMessage, contains('30'));
      expect(state.isCancelling, isFalse);
    });

    test('10. successful cancellation clears state', () async {
      final repo = _FakeRepo()..active = _searchingBooking();
      final container = _container(repo);
      addTearDown(container.dispose);

      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_seededSearchingState());
      final ok = await c.cancelActiveBooking();
      expect(ok, isTrue);
      final state = container.read(rideBookingControllerProvider);
      expect(state.bookingId, isNull);
      expect(state.hasActiveBooking, isFalse);
      expect(state.cancelIdempotencyKey, isNull);
    });

    test('12. minimize keeps booking without cancel API', () async {
      final repo = _FakeRepo()..active = _searchingBooking();
      final container = _container(repo);
      addTearDown(container.dispose);

      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_seededSearchingState());
      expect(
        container.read(rideBookingControllerProvider).bookingId,
        isNotNull,
      );

      c.minimizeActiveRide();

      final state = container.read(rideBookingControllerProvider);
      expect(state.bookingId, 'b-search');
      expect(state.hasActiveBooking, isTrue);
      expect(repo.cancelCalls, 0);
    });

    test('restore searching booking without force navigation', () async {
      final repo = _FakeRepo()..active = _searchingBooking();
      final container = _container(repo);
      addTearDown(container.dispose);

      final c = container.read(rideBookingControllerProvider.notifier);
      final restored = await c.restoreActiveBooking(navigate: false);
      expect(restored, isTrue);
      final state = container.read(rideBookingControllerProvider);
      expect(state.bookingId, 'b-search');
      expect(state.hasActiveBooking, isTrue);
      expect(state.isSearchingForDriver, isTrue);
    });

    test('restore accepted booking maps to assigned phase', () async {
      final repo = _FakeRepo()
        ..active = const BookingEntity(
          id: 'b-accepted',
          status: 'accepted',
          serviceName: 'Ride',
          serviceCategoryId: 'r1',
        );
      final container = _container(repo);
      addTearDown(container.dispose);

      final restored = await container
          .read(rideBookingControllerProvider.notifier)
          .restoreActiveBooking(navigate: false);
      expect(restored, isTrue);
      final state = container.read(rideBookingControllerProvider);
      expect(state.isAssignedRidePhase, isTrue);
      expect(state.activeRideStatusLabel, 'Driver is on the way');
    });
  });

  group('Home active ride card widget', () {
    testWidgets('shows searching card and View ride', (tester) async {
      final repo = _FakeRepo()..active = _searchingBooking();
      final container = _container(repo);
      addTearDown(container.dispose);
      container
          .read(rideBookingControllerProvider.notifier)
          .debugSeedState(_seededSearchingState());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: HomeActiveRideCard())),
        ),
      );
      await tester.pump();

      expect(find.text('Finding a driver…'), findsOneWidget);
      expect(find.text('View ride'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.textContaining('Dhanmondi'), findsOneWidget);
    });
  });
}
