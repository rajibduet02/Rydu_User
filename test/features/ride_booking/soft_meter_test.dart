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
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/fare_estimate_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/pickup_spot_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_booking_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_destination_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_option_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/domain/repositories/ride_booking_repository.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';
import 'package:rydu_user/features/ride_tracking/presentation/widgets/soft_meter_panel.dart';

class _MeterFakeRepo implements RideBookingRepository {
  PassengerMeterSnapshot meter = PassengerMeterSnapshot.empty;
  Object? meterError;
  int meterCalls = 0;
  int paymentCalls = 0;
  BookingEntity? active;

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
      const PaymentConfigEntity(stripeEnabled: true, cardEnabled: true);

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
  Future<BookingPaymentEntity> bookingPayment(String bookingId) async {
    paymentCalls++;
    return const BookingPaymentEntity(
      paymentMethod: 'card',
      status: 'authorized',
    );
  }

  @override
  Future<BookingEntity?> activeBooking() async => active;

  @override
  Future<BookingEntity?> bookingById(String bookingId) async => active;

  @override
  Future<BookingEntity?> cancelBooking(
    String bookingId, {
    String? reason,
    String? idempotencyKey,
  }) async => BookingEntity(id: bookingId, status: 'cancelled');

  @override
  Future<RecordingConsentResult> submitRecordingConsent({
    required String bookingId,
    required bool consent,
  }) async => RecordingConsentResult(consent: consent);

  @override
  Future<PassengerMeterSnapshot> bookingMeter(String bookingId) async {
    meterCalls++;
    if (meterError != null) {
      final err = meterError!;
      // ignore: only_throw_errors
      throw err;
    }
    return meter;
  }

  @override
  Future<MeterPaymentRecord?> meterPayment(String bookingId) async => null;

  @override
  Future<MeterPaymentIntentResult> createMeterPaymentIntent(
    String bookingId,
  ) async => const MeterPaymentIntentResult();

  @override
  Future<MeterPaymentRecord?> meterPaymentReceipt(String bookingId) async =>
      null;

  @override
  Future<MeterPaymentRecord?> unpaidMeterPayment() async => null;
}

RideBookingState _inProgressState({
  String bookingId = 'b-meter',
  String estimatedFare = 'USD 25.00',
  PassengerMeterSnapshot? meter,
}) {
  return RideBookingState(
    bookingId: bookingId,
    bookingStatus: 'in_progress',
    phase: RidePlanningPhase.rideInProgress,
    estimatedFare: estimatedFare,
    fareCurrency: 'USD',
    assignedDriver: const AssignedDriverEntity(id: 'd1', name: 'Karim'),
    pickupLocation: 'Coronado',
    isPickupResolved: true,
    pickupSource: PickupSource.currentLocation,
    pickupPlace: const PlaceEntity(
      placeId: '',
      label: 'Coronado',
      address: 'Coronado',
      latitude: 32.68,
      longitude: -117.18,
    ),
    dropoffPlace: const PlaceEntity(
      placeId: 'd1',
      label: 'SAN',
      address: 'SAN',
      latitude: 32.73,
      longitude: -117.19,
    ),
    selectedVehicle: const RideOptionEntity(
      id: 'svc1',
      name: 'Sedan',
      category: 'recommended',
      time: '',
      description: '',
      price: 'USD 25.00',
    ),
    selectedVehicleId: 'svc1',
    socketStatus: ActiveRideSocketStatus.connected,
    meter: meter,
  );
}

ProviderContainer _container(_MeterFakeRepo repo) {
  final goRouter = GoRouter(
    initialLocation: RouteNames.driverFound,
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

Map<String, dynamic> _runningMeterJson({
  String bookingId = 'b-meter',
  int stateVersion = 4,
  double fare = 12.5,
}) {
  return {
    'bookingId': bookingId,
    'quotedFareUnchanged': true,
    'settlement': {'billable': false, 'status': 'preview'},
    'meter': {
      'sessionId': 'ms-1',
      'sessionType': 'on_demand',
      'status': 'running',
      'stateVersion': stateVersion,
      'fareFrozen': false,
      'provisionalFare': {'amount': fare, 'currency': 'USD'},
      'traveledDistanceMiles': 1.25,
      'tripElapsedSeconds': 492,
      'chargeableElapsedSeconds': 460,
      'pauseDurationSeconds': 32,
    },
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Soft Meter parser', () {
    test('meter: null is an empty session', () {
      final parsed = RidePlanningParsers.passengerMeter({
        'bookingId': 'b-meter',
        'meter': null,
        'quotedFareUnchanged': true,
      });
      expect(parsed.hasSession, isFalse);
      expect(parsed.quotedFareUnchanged, isTrue);
      expect(parsed.bookingId, 'b-meter');
    });

    test('running meter reads backend fields only', () {
      final parsed = RidePlanningParsers.passengerMeter(_runningMeterJson());
      expect(parsed.hasSession, isTrue);
      expect(parsed.status, SoftMeterStatus.running);
      expect(parsed.stateVersion, 4);
      expect(parsed.provisionalFare, 12.5);
      expect(parsed.currency, 'USD');
      expect(parsed.traveledDistanceMiles, 1.25);
      expect(parsed.tripElapsedSeconds, 492);
      expect(parsed.chargeableElapsedSeconds, 460);
      expect(parsed.pauseDurationSeconds, 32);
      expect(parsed.quotedFareUnchanged, isTrue);
      expect(parsed.settlement?.billable, isFalse);
      expect(parsed.isWalkUp, isFalse);
    });

    test('paused and frozen flags', () {
      final paused = RidePlanningParsers.passengerMeter({
        'bookingId': 'b-meter',
        'meter': {
          'status': 'paused',
          'stateVersion': 5,
          'fareFrozen': true,
          'provisionalFare': 11.1,
          'currency': 'USD',
        },
      });
      expect(paused.status, SoftMeterStatus.paused);
      expect(paused.fareFrozen, isTrue);
      expect(paused.isPausedDisplay, isTrue);

      final frozenRunning = RidePlanningParsers.passengerMeter({
        'bookingId': 'b-meter',
        'status': 'running',
        'fare_frozen': true,
        'provisional_fare': 9.0,
        'state_version': 2,
      });
      expect(frozenRunning.isPausedDisplay, isTrue);
    });

    test('review-required meter', () {
      final parsed = RidePlanningParsers.passengerMeter({
        'meter': {
          'status': 'review_required',
          'reviewRequired': true,
          'provisionalFare': 14.0,
        },
      });
      expect(parsed.status, SoftMeterStatus.reviewRequired);
      expect(parsed.isReviewRequiredDisplay, isTrue);
    });
  });

  group('Soft Meter controller', () {
    test('no meter session is hidden', () {
      const state = RideBookingState(
        bookingId: 'b-meter',
        phase: RidePlanningPhase.rideInProgress,
      );
      expect(state.shouldShowSoftMeter, isFalse);
    });

    test('running meter is shown and quoted fare stays the booking quote', () async {
      final repo = _MeterFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      c.debugHandleMeterEvent({
        'event': 'meter:state',
        ..._runningMeterJson(),
      });
      final state = container.read(rideBookingControllerProvider);
      expect(state.shouldShowSoftMeter, isTrue);
      expect(state.meter?.status, SoftMeterStatus.running);
      expect(state.estimatedFare, 'USD 25.00');
      expect(state.meter?.quotedFareUnchanged, isTrue);
    });

    test('paused meter shows frozen fare without replacing quote', () {
      final repo = _MeterFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      c.debugHandleMeterEvent({
        'event': 'meter:state',
        'bookingId': 'b-meter',
        'meter': {
          'status': 'paused',
          'stateVersion': 6,
          'fareFrozen': true,
          'provisionalFare': 13.4,
          'currency': 'USD',
        },
      });
      final state = container.read(rideBookingControllerProvider);
      expect(state.meter?.isPausedDisplay, isTrue);
      expect(state.meter?.formattedProvisionalFare, 'USD 13.40');
      expect(state.estimatedFare, 'USD 25.00');
    });

    test('resume uses a newer backend status', () {
      final repo = _MeterFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      c.debugHandleMeterEvent({
        'event': 'meter:state',
        'bookingId': 'b-meter',
        'meter': {
          'status': 'paused',
          'stateVersion': 6,
          'fareFrozen': true,
          'provisionalFare': 13.4,
        },
      });
      c.debugHandleMeterEvent({
        'event': 'meter:state',
        'bookingId': 'b-meter',
        'meter': {
          'status': 'running',
          'stateVersion': 7,
          'fareFrozen': false,
          'provisionalFare': 13.9,
        },
      });
      final state = container.read(rideBookingControllerProvider);
      expect(state.meter?.status, SoftMeterStatus.running);
      expect(state.meter?.fareFrozen, isFalse);
      expect(state.meter?.stateVersion, 7);
    });

    test('stale stateVersion cannot overwrite a newer paused state', () {
      final repo = _MeterFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      c.debugHandleMeterEvent({
        'event': 'meter:state',
        'bookingId': 'b-meter',
        'meter': {
          'status': 'paused',
          'stateVersion': 8,
          'fareFrozen': true,
          'provisionalFare': 15.0,
        },
      });
      c.debugHandleMeterEvent({
        'event': 'meter:fare',
        'bookingId': 'b-meter',
        'status': 'running',
        'stateVersion': 4,
        'fareFrozen': false,
        'provisionalFare': 99.0,
      });
      final state = container.read(rideBookingControllerProvider);
      expect(state.meter?.status, SoftMeterStatus.paused);
      expect(state.meter?.provisionalFare, 15.0);
      expect(state.meter?.stateVersion, 8);
    });

    test('unrelated booking events are ignored', () {
      final repo = _MeterFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      c.debugHandleMeterEvent({
        'event': 'meter:state',
        'bookingId': 'other-booking',
        'meter': {
          'status': 'running',
          'stateVersion': 1,
          'provisionalFare': 40.0,
        },
      });
      final state = container.read(rideBookingControllerProvider);
      expect(state.meter, isNull);
      expect(state.shouldShowSoftMeter, isFalse);
    });

    test('REST restoration applies the server snapshot', () async {
      final repo = _MeterFakeRepo()
        ..meter = RidePlanningParsers.passengerMeter(
          _runningMeterJson(stateVersion: 9, fare: 16.2),
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      await c.refreshMeterFromBackend();
      final state = container.read(rideBookingControllerProvider);
      expect(repo.meterCalls, 1);
      expect(repo.paymentCalls, 0);
      expect(state.meter?.stateVersion, 9);
      expect(state.meter?.provisionalFare, 16.2);
      expect(state.estimatedFare, 'USD 25.00');
    });

    test('meter endpoint failure does not change quoted fare or Stripe', () async {
      final repo = _MeterFakeRepo()
        ..meterError = const PassengerApiException(
          'Meter unavailable',
          code: 'NETWORK',
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      await c.refreshMeterFromBackend();
      final state = container.read(rideBookingControllerProvider);
      expect(state.estimatedFare, 'USD 25.00');
      expect(state.meter, isNull);
      expect(repo.paymentCalls, 0);
    });

    test('walk-up sessions stay hidden in the passenger app', () {
      const state = RideBookingState(
        bookingId: 'b-meter',
        phase: RidePlanningPhase.rideInProgress,
        meter: PassengerMeterSnapshot(
          bookingId: 'b-meter',
          sessionType: 'walk_up',
          status: SoftMeterStatus.running,
          provisionalFare: 8,
        ),
      );
      expect(state.meter?.isWalkUp, isTrue);
      expect(state.shouldShowSoftMeter, isFalse);
    });

    test('completed ride keeps quoted fare and hides the meter panel', () {
      final state = _inProgressState(
        meter: const PassengerMeterSnapshot(
          status: SoftMeterStatus.running,
          provisionalFare: 18,
          currency: 'USD',
        ),
      );
      expect(state.shouldShowSoftMeter, isTrue);

      const completed = RideBookingState(
        bookingId: 'b-meter',
        phase: RidePlanningPhase.completed,
        estimatedFare: 'USD 25.00',
        meter: PassengerMeterSnapshot(
          status: SoftMeterStatus.finalized,
          provisionalFare: 18,
          settlement: MeterSettlement(billable: false),
        ),
      );
      expect(completed.shouldShowSoftMeter, isFalse);
      expect(completed.estimatedFare, 'USD 25.00');
      expect(completed.meter?.isFinalizedNonBillable, isTrue);
    });
  });

  group('Soft Meter UI', () {
    testWidgets('running panel shows live meter fare without a booking quote', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SoftMeterPanel(
              meter: RidePlanningParsers.passengerMeter(_runningMeterJson()),
            ),
          ),
        ),
      );

      expect(find.text('Soft Meter'), findsOneWidget);
      expect(
        find.text(
          'Live meter fare — final amount confirmed when your ride ends.',
        ),
        findsOneWidget,
      );
      expect(find.text('Booking quote'), findsNothing);
      expect(find.text('USD 25.00'), findsNothing);
      expect(find.text('USD 12.50'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
      expect(find.text('Resume'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('paused panel has no passenger Pause/Resume controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SoftMeterPanel(
              meter: PassengerMeterSnapshot(
                status: SoftMeterStatus.paused,
                fareFrozen: true,
                provisionalFare: 13.4,
                currency: 'USD',
                pauseDurationSeconds: 45,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Soft Meter Paused'), findsOneWidget);
      expect(
        find.text('Distance and time charges are suspended.'),
        findsOneWidget,
      );
      expect(find.text('USD 13.40'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
      expect(find.text('Resume'), findsNothing);
      expect(find.text('Pay now'), findsNothing);
    });
  });

  group('Stopped-time fare display', () {
    Map<String, dynamic> breakdownJson({
      int stateVersion = 10,
      int waitingChargeCents = 325,
      int billedMinutes = 2,
      int unbilledSeconds = 15,
      int eligibleSeconds = 135,
    }) {
      return {
        'bookingId': 'b-meter',
        'quotedFareUnchanged': true,
        'meter': {
          'sessionId': 'ms-1',
          'sessionType': 'on_demand',
          'status': 'running',
          'stateVersion': stateVersion,
          'fareFrozen': false,
          'traveledDistanceMiles': 1.25,
          'eligibleStoppedSeconds': eligibleSeconds,
          'waitingSeconds': 400,
          'excludedStopSeconds': 20,
          'stopStreak': 1,
          'stopPolicy': 'stationary_confirmed',
          'fare': {
            'flagDropCents': 350,
            'distanceChargeCents': 1200,
            'waitingChargeCents': waitingChargeCents,
            'totalCents': 1875,
            'billedStoppedMinutes': billedMinutes,
            'unbilledStoppedRemainderSeconds': unbilledSeconds,
            'waitingPolicyApplied': true,
            'distanceTimePolicyApplied': true,
          },
        },
      };
    }

    test('parses nested fare cents and meter-level stopped time', () {
      final parsed = RidePlanningParsers.passengerMeter(breakdownJson());
      expect(parsed.flagDropCents, 350);
      expect(parsed.distanceChargeCents, 1200);
      expect(parsed.waitingChargeCents, 325);
      expect(parsed.totalCents, 1875);
      expect(parsed.billedStoppedMinutes, 2);
      expect(parsed.unbilledStoppedRemainderSeconds, 15);
      expect(parsed.eligibleStoppedSeconds, 135);
      expect(parsed.waitingSeconds, 400);
      expect(parsed.excludedStopSeconds, 20);
      expect(parsed.stopStreak, 1);
      expect(parsed.stopPolicy, 'stationary_confirmed');
      expect(parsed.waitingPolicyApplied, isTrue);
      expect(parsed.distanceTimePolicyApplied, isTrue);
      expect(parsed.displayedEligibleStoppedSeconds, 135);
      expect(parsed.formattedProvisionalFare, 'USD 18.75');
      expect(parsed.formattedFlagDrop, 'USD 3.50');
      expect(parsed.formattedDistanceCharge, 'USD 12.00');
      expect(parsed.formattedWaitingCharge, 'USD 3.25');
    });

    test('snake_case fare aliases parse without fabricating values', () {
      final parsed = RidePlanningParsers.passengerMeter({
        'booking_id': 'b-meter',
        'meter': {
          'status': 'running',
          'eligible_stopped_seconds': 60,
          'waiting_seconds': 60,
          'fare_breakdown': {
            'flag_drop_cents': 250,
            'distance_charge_cents': 400,
            'waiting_charge_cents': 100,
            'total_cents': 750,
            'billed_stopped_minutes': 1,
            'unbilled_stopped_remainder_seconds': 0,
            'waiting_policy_applied': false,
            'distance_time_policy_applied': true,
          },
        },
      });
      expect(parsed.flagDropCents, 250);
      expect(parsed.waitingChargeCents, 100);
      expect(parsed.totalCents, 750);
      expect(parsed.unbilledStoppedRemainderSeconds, 0);
      expect(parsed.waitingPolicyApplied, isFalse);
    });

    test('explicit zero waiting charge is kept, not treated as missing', () {
      final parsed = RidePlanningParsers.passengerMeter(
        breakdownJson(waitingChargeCents: 0),
      );
      expect(parsed.waitingChargeCents, 0);
      expect(parsed.formattedWaitingCharge, 'USD 0.00');
    });

    test('waitingSeconds is fallback only when eligibleStoppedSeconds is absent', () {
      final withEligible = RidePlanningParsers.passengerMeter(breakdownJson());
      expect(withEligible.displayedEligibleStoppedSeconds, 135);

      final fallback = RidePlanningParsers.passengerMeter({
        'meter': {
          'status': 'running',
          'waitingSeconds': 90,
          'fare': {'totalCents': 500},
        },
      });
      expect(fallback.eligibleStoppedSeconds, isNull);
      expect(fallback.waitingSeconds, 90);
      expect(fallback.displayedEligibleStoppedSeconds, 90);
    });

    test('missing optional fare fields stay null', () {
      final parsed = RidePlanningParsers.passengerMeter({
        'bookingId': 'b-meter',
        'meter': {
          'status': 'running',
          'stateVersion': 1,
          'provisionalFare': 10.0,
          'currency': 'USD',
        },
      });
      expect(parsed.flagDropCents, isNull);
      expect(parsed.distanceChargeCents, isNull);
      expect(parsed.waitingChargeCents, isNull);
      expect(parsed.totalCents, isNull);
      expect(parsed.billedStoppedMinutes, isNull);
      expect(parsed.unbilledStoppedRemainderSeconds, isNull);
      expect(parsed.eligibleStoppedSeconds, isNull);
      expect(parsed.formattedFlagDrop, isNull);
      expect(parsed.formattedWaitingCharge, isNull);
    });

    testWidgets('combined distance and stopped-time rows render backend values', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SoftMeterPanel(
              meter: RidePlanningParsers.passengerMeter(breakdownJson()),
            ),
          ),
        ),
      );

      expect(find.text('USD 25.00'), findsNothing);
      expect(find.text('USD 18.75'), findsOneWidget);
      expect(find.text('Initial flag drop'), findsOneWidget);
      expect(find.text('USD 3.50'), findsOneWidget);
      expect(find.text('Distance traveled'), findsOneWidget);
      expect(find.text('1.25 mi'), findsOneWidget);
      expect(find.text('Distance charge'), findsOneWidget);
      expect(find.text('USD 12.00'), findsOneWidget);
      expect(find.text('Eligible stopped time'), findsOneWidget);
      expect(find.text('2:15'), findsOneWidget);
      expect(find.text('Stopped-time charge'), findsOneWidget);
      expect(find.text('USD 3.25'), findsOneWidget);
      expect(find.text('Billed stopped minutes'), findsOneWidget);
      expect(find.text('2 min'), findsOneWidget);
      expect(find.text('Unbilled remainder'), findsOneWidget);
      expect(find.text('0:15'), findsOneWidget);
      expect(
        find.text(
          'Live meter fare — final amount confirmed when your ride ends.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Stopped-time charges apply only when the vehicle is confirmed stationary.',
        ),
        findsOneWidget,
      );
      expect(find.text('Checkout'), findsNothing);
      expect(find.text('Pay now'), findsNothing);
      expect(find.text('QR'), findsNothing);
    });

    testWidgets('explicit zero waiting charge is visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SoftMeterPanel(
              meter: RidePlanningParsers.passengerMeter(
                breakdownJson(waitingChargeCents: 0),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Stopped-time charge'), findsOneWidget);
      expect(find.text('USD 0.00'), findsOneWidget);
    });

    testWidgets('missing optional fields omit those rows', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SoftMeterPanel(
              meter: PassengerMeterSnapshot(
                status: SoftMeterStatus.running,
                provisionalFare: 10,
                currency: 'USD',
                traveledDistanceMiles: 0.4,
              ),
            ),
          ),
        ),
      );
      expect(find.text('USD 10.00'), findsOneWidget);
      expect(find.text('Distance traveled'), findsOneWidget);
      expect(find.text('Initial flag drop'), findsNothing);
      expect(find.text('Distance charge'), findsNothing);
      expect(find.text('Stopped-time charge'), findsNothing);
      expect(find.text('Billed stopped minutes'), findsNothing);
      expect(find.text('Unbilled remainder'), findsNothing);
      expect(find.text('Eligible stopped time'), findsNothing);
    });

    test('paused fare and stopped-time stay frozen against stale events', () {
      final repo = _MeterFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      c.debugHandleMeterEvent({
        'event': 'meter:state',
        'bookingId': 'b-meter',
        'meter': {
          'status': 'paused',
          'stateVersion': 12,
          'fareFrozen': true,
          'eligibleStoppedSeconds': 135,
          'fare': {
            'waitingChargeCents': 325,
            'totalCents': 1875,
            'billedStoppedMinutes': 2,
            'unbilledStoppedRemainderSeconds': 15,
          },
        },
      });
      c.debugHandleMeterEvent({
        'event': 'meter:fare',
        'bookingId': 'b-meter',
        'status': 'running',
        'stateVersion': 9,
        'eligibleStoppedSeconds': 999,
        'fare': {
          'waitingChargeCents': 800,
          'totalCents': 9999,
          'billedStoppedMinutes': 8,
        },
      });
      final state = container.read(rideBookingControllerProvider);
      expect(state.meter?.isPausedDisplay, isTrue);
      expect(state.meter?.eligibleStoppedSeconds, 135);
      expect(state.meter?.waitingChargeCents, 325);
      expect(state.meter?.totalCents, 1875);
      expect(state.meter?.billedStoppedMinutes, 2);
      expect(state.estimatedFare, 'USD 25.00');
    });

    test('reconnect REST refresh replaces frozen values from backend', () async {
      final repo = _MeterFakeRepo()
        ..meter = RidePlanningParsers.passengerMeter(
          breakdownJson(stateVersion: 20, eligibleSeconds: 180),
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        _inProgressState(
          meter: const PassengerMeterSnapshot(
            status: SoftMeterStatus.paused,
            fareFrozen: true,
            stateVersion: 12,
            eligibleStoppedSeconds: 135,
            waitingChargeCents: 325,
            totalCents: 1875,
          ),
        ),
      );

      await c.refreshMeterFromBackend();
      final state = container.read(rideBookingControllerProvider);
      expect(repo.meterCalls, 1);
      expect(repo.paymentCalls, 0);
      expect(state.meter?.stateVersion, 20);
      expect(state.meter?.eligibleStoppedSeconds, 180);
      expect(state.meter?.waitingChargeCents, 325);
      expect(state.estimatedFare, 'USD 25.00');
    });

    test('unrelated booking stopped-time event is ignored', () {
      final repo = _MeterFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_inProgressState());

      c.debugHandleMeterEvent({
        'event': 'meter:fare',
        ...breakdownJson(),
        'bookingId': 'other-booking',
      });
      final state = container.read(rideBookingControllerProvider);
      expect(state.meter, isNull);
      expect(state.estimatedFare, 'USD 25.00');
    });

    test('walk-up meter with fare cents stays hidden and is not a payment', () {
      const state = RideBookingState(
        bookingId: 'b-meter',
        phase: RidePlanningPhase.rideInProgress,
        estimatedFare: 'USD 25.00',
        meter: PassengerMeterSnapshot(
          bookingId: 'b-meter',
          sessionType: 'walk_up',
          status: SoftMeterStatus.running,
          totalCents: 2200,
          waitingChargeCents: 400,
        ),
      );
      expect(state.shouldShowSoftMeter, isFalse);
      expect(state.estimatedFare, 'USD 25.00');
    });
  });
}
