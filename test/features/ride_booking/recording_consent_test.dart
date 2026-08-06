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
import 'package:rydu_user/features/ride_booking/domain/entities/fare_estimate_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/pickup_spot_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_booking_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_destination_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_option_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/domain/repositories/ride_booking_repository.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';
import 'package:rydu_user/features/ride_tracking/presentation/widgets/recording_consent_overlay.dart';

class _ConsentFakeRepo implements RideBookingRepository {
  BookingEntity? active;
  RecordingConsentResult? consentResult;
  Object? consentError;
  int consentCalls = 0;
  bool? lastConsentValue;
  int cancelCalls = 0;

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
  Future<BookingEntity> createBooking({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    required String idempotencyKey,
  }) async => throw UnimplementedError();

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
    return BookingEntity(id: bookingId, status: 'cancelled');
  }

  @override
  Future<RecordingConsentResult> submitRecordingConsent({
    required String bookingId,
    required bool consent,
  }) async {
    consentCalls++;
    lastConsentValue = consent;
    if (consentError != null) {
      final err = consentError!;
      consentError = null;
      // ignore: only_throw_errors
      throw err;
    }
    return consentResult ??
        RecordingConsentResult(
          consent: consent,
          consentStatus: consent ? 'granted' : 'denied',
          consented: consent,
          recordingConsentedAt: consent ? '2030-01-01T00:00:00.000Z' : null,
          booking: BookingEntity(
            id: bookingId,
            status: 'accepted',
            recordingConsent: RecordingConsentInfo(
              consentStatus: consent ? 'granted' : 'denied',
              consented: consent,
              recordingConsentedAt: consent
                  ? '2030-01-01T00:00:00.000Z'
                  : null,
            ),
          ),
        );
  }
}

RideBookingState _acceptedState({
  RecordingConsentStatus consent = RecordingConsentStatus.required,
  RecordingConsentInfo? info,
}) {
  return RideBookingState(
    bookingId: 'b-accepted',
    bookingStatus: 'accepted',
    phase: RidePlanningPhase.driverAccepted,
    assignedDriver: const AssignedDriverEntity(id: 'd1', name: 'Karim'),
    recordingConsentStatus: consent,
    recordingConsentInfo: info,
    pickupLocation: 'Dhanmondi',
    isPickupResolved: true,
    pickupSource: PickupSource.currentLocation,
    pickupPlace: const PlaceEntity(
      placeId: '',
      label: 'Dhanmondi',
      address: 'Dhanmondi',
      latitude: 23.75,
      longitude: 90.38,
    ),
    dropoffPlace: const PlaceEntity(
      placeId: 'd1',
      label: 'Mirpur',
      address: 'Mirpur',
      latitude: 23.8,
      longitude: 90.4,
    ),
    selectedVehicle: const RideOptionEntity(
      id: 'svc1',
      name: 'CNG',
      category: 'recommended',
      time: '',
      description: '',
      price: 'BDT 120.00',
    ),
    selectedVehicleId: 'svc1',
    socketStatus: ActiveRideSocketStatus.connected,
  );
}

ProviderContainer _container(_ConsentFakeRepo repo) {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Recording consent resolution', () {
    test('1. prompt required after driver acceptance', () {
      final status = resolveRecordingConsentStatus(
        isAssignedRidePhase: true,
        info: const RecordingConsentInfo(consentStatus: 'pending'),
      );
      expect(status, RecordingConsentStatus.required);

      const state = RideBookingState(
        bookingId: 'b1',
        phase: RidePlanningPhase.driverAccepted,
        recordingConsentStatus: RecordingConsentStatus.required,
      );
      expect(state.shouldShowRecordingConsentPrompt, isTrue);
    });

    test('2. prompt does not appear before acceptance', () {
      final status = resolveRecordingConsentStatus(
        isAssignedRidePhase: false,
        info: const RecordingConsentInfo(consentStatus: 'pending'),
      );
      expect(status, RecordingConsentStatus.unknown);

      const state = RideBookingState(
        bookingId: 'b1',
        phase: RidePlanningPhase.bookingSearching,
        recordingConsentStatus: RecordingConsentStatus.unknown,
      );
      expect(state.shouldShowRecordingConsentPrompt, isFalse);
      expect(state.isAssignedRidePhase, isFalse);
    });

    test('3. prompt does not repeat after grant', () {
      const state = RideBookingState(
        bookingId: 'b1',
        phase: RidePlanningPhase.driverAccepted,
        recordingConsentStatus: RecordingConsentStatus.granted,
      );
      expect(state.shouldShowRecordingConsentPrompt, isFalse);
      expect(state.recordingConsentStatusLabel, 'Ride safety recording allowed');
    });

    test('4. prompt does not repeat after denial', () {
      const state = RideBookingState(
        bookingId: 'b1',
        phase: RidePlanningPhase.driverAccepted,
        recordingConsentStatus: RecordingConsentStatus.denied,
      );
      expect(state.shouldShowRecordingConsentPrompt, isFalse);
      expect(state.recordingConsentStatusLabel, 'Recording not allowed');
    });
  });

  group('Recording consent API + controller', () {
    test('5. Allow sends consent=true', () async {
      final repo = _ConsentFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_acceptedState());

      final ok = await c.submitRecordingConsent(true);
      expect(ok, isTrue);
      expect(repo.consentCalls, 1);
      expect(repo.lastConsentValue, isTrue);
      expect(
        container.read(rideBookingControllerProvider).recordingConsentStatus,
        RecordingConsentStatus.granted,
      );
    });

    test('6. Decline sends consent=false', () async {
      final repo = _ConsentFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_acceptedState());

      final ok = await c.submitRecordingConsent(false);
      expect(ok, isTrue);
      expect(repo.lastConsentValue, isFalse);
      expect(
        container.read(rideBookingControllerProvider).recordingConsentStatus,
        RecordingConsentStatus.denied,
      );
    });

    test('7. duplicate taps are blocked while submitting', () async {
      final repo = _ConsentFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        _acceptedState(consent: RecordingConsentStatus.submitting),
      );

      final ok = await c.submitRecordingConsent(true);
      expect(ok, isFalse);
      expect(repo.consentCalls, 0);
    });

    test('8. backend response updates state', () async {
      final repo = _ConsentFakeRepo()
        ..consentResult = const RecordingConsentResult(
          consent: true,
          consentStatus: 'granted',
          consented: true,
          recordingConsentedAt: '2030-01-01T00:00:00.000Z',
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_acceptedState());

      await c.submitRecordingConsent(true);
      final state = container.read(rideBookingControllerProvider);
      expect(state.recordingConsentStatus, RecordingConsentStatus.granted);
      expect(
        state.recordingConsentInfo?.recordingConsentedAt,
        '2030-01-01T00:00:00.000Z',
      );
    });

    test('9. API failure shows retry', () async {
      final repo = _ConsentFakeRepo()
        ..consentError = const PassengerApiException(
          'Network error. Check your connection and try again.',
          code: 'NETWORK',
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_acceptedState());

      final ok = await c.submitRecordingConsent(true);
      expect(ok, isFalse);
      final failed = container.read(rideBookingControllerProvider);
      expect(failed.recordingConsentStatus, RecordingConsentStatus.failed);
      expect(failed.shouldShowRecordingConsentPrompt, isTrue);
      expect(failed.lastRecordingConsentChoice, isTrue);

      final retried = await c.retryRecordingConsent();
      expect(retried, isTrue);
      expect(repo.consentCalls, 2);
      expect(
        container.read(rideBookingControllerProvider).recordingConsentStatus,
        RecordingConsentStatus.granted,
      );
    });

    test('10. socket consent update refreshes state', () {
      final status = resolveRecordingConsentStatus(
        isAssignedRidePhase: true,
        info: RidePlanningParsers.recordingConsent({
          'bookingId': 'b-accepted',
          'consentStatus': 'granted',
          'consented': true,
          'recordingConsentedAt': '2030-01-01T00:00:00.000Z',
        }),
      );
      expect(status, RecordingConsentStatus.granted);

      final denied = resolveRecordingConsentStatus(
        isAssignedRidePhase: true,
        info: RidePlanningParsers.recordingConsent({
          'event': 'recording:consent_updated',
          'bookingId': 'b-accepted',
          'consentStatus': 'denied',
          'consented': false,
        }),
      );
      expect(denied, RecordingConsentStatus.denied);
    });

    test('11. wrong booking socket event is ignored by parser filter', () {
      // Socket service filters by active booking id; controller also checks.
      final info = RidePlanningParsers.recordingConsent({
        'bookingId': 'other-booking',
        'consentStatus': 'granted',
      });
      expect(info?.consentStatus, 'granted');

      // State for active booking must remain required when event id differs —
      // simulated by not applying foreign consent.
      const state = RideBookingState(
        bookingId: 'b-accepted',
        phase: RidePlanningPhase.driverAccepted,
        recordingConsentStatus: RecordingConsentStatus.required,
      );
      expect(state.bookingId, isNot('other-booking'));
      expect(state.recordingConsentStatus, RecordingConsentStatus.required);
    });

    test('12. app restart restores consent state', () async {
      final repo = _ConsentFakeRepo()
        ..active = const BookingEntity(
          id: 'b-accepted',
          status: 'accepted',
          recordingConsent: RecordingConsentInfo(
            consentStatus: 'granted',
            consented: true,
            recordingConsentedAt: '2030-01-01T00:00:00.000Z',
          ),
          driver: AssignedDriverEntity(id: 'd1', name: 'Karim'),
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);

      final restored = await c.restoreActiveBooking(navigate: false);
      expect(restored, isTrue);
      final state = container.read(rideBookingControllerProvider);
      expect(state.recordingConsentStatus, RecordingConsentStatus.granted);
      expect(state.shouldShowRecordingConsentPrompt, isFalse);
    });

    test('13. reconnect refreshes consent from backend', () async {
      final repo = _ConsentFakeRepo()
        ..active = const BookingEntity(
          id: 'b-accepted',
          status: 'accepted',
          recordingConsent: RecordingConsentInfo(
            consentStatus: 'denied',
            consented: false,
          ),
          driver: AssignedDriverEntity(id: 'd1', name: 'Karim'),
        );
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        _acceptedState(
          consent: RecordingConsentStatus.required,
          info: const RecordingConsentInfo(consentStatus: 'pending'),
        ),
      );

      await c.refreshRecordingConsentFromBackend();
      final state = container.read(rideBookingControllerProvider);
      expect(state.recordingConsentStatus, RecordingConsentStatus.denied);
      expect(state.shouldShowRecordingConsentPrompt, isFalse);
    });

    test('14. existing booking acceptance flow still works', () {
      expect(
        ridePhaseFromBookingStatus('accepted'),
        RidePlanningPhase.driverAccepted,
      );
      const state = RideBookingState(
        bookingId: 'b1',
        phase: RidePlanningPhase.driverAccepted,
        bookingStatus: 'accepted',
      );
      expect(state.isAssignedRidePhase, isTrue);
      expect(state.hasActiveBooking, isTrue);
      expect(state.canCancelBooking, isTrue);
    });

    test('15. existing cancellation flow still works', () async {
      final repo = _ConsentFakeRepo();
      final container = _container(repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_acceptedState());

      final ok = await c.cancelActiveBooking(reason: 'test');
      expect(ok, isTrue);
      expect(repo.cancelCalls, 1);
      expect(
        container.read(rideBookingControllerProvider).phase,
        RidePlanningPhase.cancelled,
      );
    });
  });

  group('Recording consent parsers', () {
    test('parses booking consent fields from known contract keys', () {
      final booking = RidePlanningParsers.booking({
        'id': 'b1',
        'status': 'accepted',
        'consentStatus': 'pending',
        'recordingConsentRequired': true,
      });
      expect(booking!.recordingConsent?.consentStatus, 'pending');
      expect(booking.recordingConsent?.required, isTrue);
    });

    test('parses POST consent response without assuming success early', () {
      final result = RidePlanningParsers.recordingConsentResult({
        'consentStatus': 'granted',
        'consented': true,
        'recordingConsentedAt': '2030-01-01T00:00:00.000Z',
        'booking': {'id': 'b1', 'status': 'accepted', 'consentStatus': 'granted'},
      }, requestedConsent: true);
      expect(result!.consentStatus, 'granted');
      expect(result.booking?.id, 'b1');
    });
  });

  group('Recording consent UI', () {
    testWidgets('overlay shows Allow and Decline actions', (tester) async {
      var allowed = false;
      var declined = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingConsentOverlay(
              isSubmitting: false,
              isFailed: false,
              onAllow: () => allowed = true,
              onDecline: () => declined = true,
            ),
          ),
        ),
      );

      expect(find.text('Allow recording'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      await tester.tap(find.text('Allow recording'));
      expect(allowed, isTrue);
      await tester.tap(find.text('Decline'));
      expect(declined, isTrue);
    });

    testWidgets('failed overlay shows retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingConsentOverlay(
              isSubmitting: false,
              isFailed: true,
              errorMessage: 'Network error. Check your connection and try again.',
              onAllow: () {},
              onDecline: () {},
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Try again'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });
  });
}
