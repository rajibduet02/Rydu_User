import 'dart:async';
import 'dart:io';

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
import 'package:rydu_user/features/ride_booking/data/services/stripe_payment_gateway.dart';
import 'package:rydu_user/features/ride_booking/data/utils/booking_create_request.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/fare_estimate_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/pickup_spot_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_booking_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_destination_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_option_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/domain/repositories/ride_booking_repository.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';

class _FakeStripe implements StripePaymentGateway {
  String? lastPublishableKey;
  String? lastClientSecret;
  StripeSheetOutcome outcome = StripeSheetOutcome.completed;
  int presentCount = 0;
  int initCount = 0;
  Future<StripeSheetOutcome> Function()? presentPaymentSheetOverride;

  @override
  Future<bool> initialize({required String publishableKey}) async {
    initCount++;
    lastPublishableKey = publishableKey;
    return publishableKey.startsWith('pk_');
  }

  @override
  Future<StripeSheetOutcome> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    presentCount++;
    lastClientSecret = clientSecret;
    if (presentPaymentSheetOverride != null) {
      return presentPaymentSheetOverride!();
    }
    return outcome;
  }
}

class _FakeStripeRepo implements RideBookingRepository {
  String? lastPaymentMethodCode;
  Map<String, dynamic>? lastCreateBody;
  int createCalls = 0;
  int paymentPolls = 0;
  CreateBookingResult? createResult;
  BookingEntity? active;
  BookingEntity? refreshed;
  final List<BookingPaymentEntity> paymentQueue = [];
  BookingPaymentEntity? lastPayment;
  PaymentConfigEntity config = const PaymentConfigEntity(
    stripeEnabled: true,
    cardEnabled: true,
    publishableKey: 'pk_test_backend',
  );
  List<PaymentMethodEntity> methods = const [
    PaymentMethodEntity(code: 'card', label: 'Card', isDefault: true),
  ];

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
  Future<List<PaymentMethodEntity>> paymentMethods() async => methods;

  @override
  Future<PaymentConfigEntity> paymentConfig() async => config;

  @override
  Future<CreateBookingResult> createBooking({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    required String idempotencyKey,
  }) async {
    createCalls++;
    lastPaymentMethodCode = paymentMethodCode;
    lastCreateBody = BookingCreateRequest.body(
      serviceCategoryId: serviceCategoryId,
      pickup: pickup,
      dropoff: dropoff,
      stops: stops,
      paymentMethodCode: paymentMethodCode,
    );
    return createResult!;
  }

  @override
  Future<BookingPaymentEntity> bookingPayment(String bookingId) async {
    paymentPolls++;
    if (paymentQueue.isNotEmpty) {
      lastPayment = paymentQueue.removeAt(0);
    }
    return lastPayment ??
        const BookingPaymentEntity(
          paymentMethod: 'card',
          status: 'authorized',
        );
  }

  @override
  Future<BookingEntity?> activeBooking() async => active;

  @override
  Future<BookingEntity?> bookingById(String bookingId) async =>
      refreshed ?? active;

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
}

const _pickup = PlaceEntity(
  placeId: 'p1',
  label: 'Dhanmondi',
  address: 'Dhanmondi',
  latitude: 23.75,
  longitude: 90.38,
);

const _dropoff = PlaceEntity(
  placeId: 'd1',
  label: 'Mirpur',
  address: 'Mirpur',
  latitude: 23.8,
  longitude: 90.4,
);

const _vehicle = RideOptionEntity(
  id: 'svc1',
  name: 'CNG',
  category: 'recommended',
  time: '',
  description: '',
  price: 'BDT 120.00',
);

RideBookingState _readyState({String paymentCode = 'card'}) {
  return RideBookingState(
    pickupPlace: _pickup,
    dropoffPlace: _dropoff,
    selectedDestination: const RideDestinationEntity(
      id: 'd1',
      name: 'Mirpur',
      address: 'Mirpur',
      distance: '',
    ),
    selectedVehicle: _vehicle,
    selectedVehicleId: 'svc1',
    estimatedFare: 'BDT 120.00',
    isPickupResolved: true,
    pickupSource: PickupSource.currentLocation,
    paymentMethod: CardBookingPayment.label,
    paymentMethodCode: paymentCode,
    paymentMethods: const [
      PaymentMethodEntity(code: 'card', label: 'Card', isDefault: true),
    ],
    phase: RidePlanningPhase.quoteLoaded,
  );
}

ProviderContainer _container({
  required _FakeStripeRepo repo,
  required _FakeStripe stripe,
}) {
  final goRouter = GoRouter(
    initialLocation: RouteNames.rideSelection,
    routes: [
      GoRoute(path: RouteNames.home, builder: (_, _) => const SizedBox()),
      GoRoute(
        path: RouteNames.rideSelection,
        builder: (_, _) => const SizedBox(),
      ),
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
      stripePaymentGatewayProvider.overrideWithValue(stripe),
      paymentPollDelayProvider.overrideWithValue((_) async {}),
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

  group('Stripe Phase C booking flow', () {
    test('9 Stripe unavailable does not silently create a cash booking', () async {
      final repo = _FakeStripeRepo()
        ..config = const PaymentConfigEntity(
          stripeEnabled: false,
          cardEnabled: false,
        );
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_readyState(paymentCode: 'cash'));
      await c.confirmBooking();
      expect(repo.createCalls, 0);
      expect(stripe.presentCount, 0);
      final state = container.read(rideBookingControllerProvider);
      expect(state.errorMessage, CardBookingPayment.unavailableMessage);
      expect(state.phase, RidePlanningPhase.quoteLoaded);
      expect(state.isSearchingForDriver, isFalse);
    });

    test('9b Card missing from payment methods does not create a cash booking', () async {
      final repo = _FakeStripeRepo()
        ..methods = const [
          PaymentMethodEntity(code: 'cash', label: 'Cash', isDefault: true),
        ];
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_readyState());
      await c.confirmBooking();
      expect(repo.createCalls, 0);
      expect(stripe.presentCount, 0);
      expect(
        container.read(rideBookingControllerProvider).errorMessage,
        CardBookingPayment.unavailableMessage,
      );
    });

    test('F/G booking always sends paymentMethodCode=card and no amount', () async {
      final repo = _FakeStripeRepo()
        ..createResult = const CreateBookingResult(
          booking: BookingEntity(
            id: 'b-card',
            status: 'quoted',
            paymentMethodCode: 'card',
          ),
          payment: BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'requires_payment_method',
            clientSecret: 'pi_1_secret_x',
          ),
        );
      final stripe = _FakeStripe()..outcome = StripeSheetOutcome.canceled;
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_readyState(paymentCode: 'cash'));
      await c.confirmBooking();
      expect(repo.createCalls, 1);
      expect(repo.lastPaymentMethodCode, 'card');
      expect(repo.lastCreateBody!.containsKey('amount'), isFalse);
      expect(repo.lastCreateBody!.containsKey('fare'), isFalse);
      expect(repo.lastCreateBody!.containsKey('finalFare'), isFalse);
      expect(
        container.read(rideBookingControllerProvider).isSearchingForDriver,
        isFalse,
      );
    });

    test('F/H/I/J/K card create uses PaymentSheet then polls to searching', () async {
      final repo = _FakeStripeRepo()
        ..createResult = const CreateBookingResult(
          booking: BookingEntity(
            id: 'b-card',
            status: 'quoted',
            paymentMethodCode: 'card',
          ),
          payment: BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'requires_payment_method',
            paymentIntentId: 'pi_1',
            clientSecret: 'pi_1_secret_x',
          ),
        )
        ..paymentQueue.addAll(const [
          BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'requires_payment_method',
            clientSecret: 'pi_1_secret_x',
          ),
          BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'authorized',
            paymentIntentId: 'pi_1',
          ),
        ])
        ..refreshed = const BookingEntity(
          id: 'b-card',
          status: 'searching',
          paymentMethodCode: 'card',
        );
      final gate = Completer<StripeSheetOutcome>();
      final stripe = _FakeStripe();
      stripe.outcome = StripeSheetOutcome.completed;
      // Delay PaymentSheet so quoted booking cannot look like searching yet.
      stripe.presentPaymentSheetOverride = () => gate.future;
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_readyState(paymentCode: 'card'));

      final confirm = c.confirmBooking();
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(rideBookingControllerProvider).isSearchingForDriver,
        isFalse,
      );
      expect(
        container.read(rideBookingControllerProvider).phase,
        RidePlanningPhase.paymentPending,
      );
      gate.complete(StripeSheetOutcome.completed);
      await confirm;

      expect(repo.lastPaymentMethodCode, 'card');
      expect(repo.lastCreateBody!.containsKey('amount'), isFalse);
      expect(stripe.lastPublishableKey, 'pk_test_backend');
      expect(stripe.lastClientSecret, 'pi_1_secret_x');
      expect(stripe.presentCount, 1);
      expect(repo.paymentPolls, greaterThan(0));
      final state = container.read(rideBookingControllerProvider);
      expect(state.phase, RidePlanningPhase.bookingSearching);
      expect(state.isSearchingForDriver, isTrue);
      expect(state.cardPaymentUiState, CardPaymentUiState.authorized);
    });

    test('L requires_action does not mark searching locally', () async {
      final repo = _FakeStripeRepo()
        ..createResult = const CreateBookingResult(
          booking: BookingEntity(
            id: 'b-card',
            status: 'quoted',
            paymentMethodCode: 'card',
          ),
          payment: BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'requires_action',
            clientSecret: 'pi_1_secret_x',
          ),
        )
        ..paymentQueue.add(
          const BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'requires_action',
            clientSecret: 'pi_1_secret_x',
          ),
        );
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_readyState(paymentCode: 'card'));
      await c.confirmBooking();
      final state = container.read(rideBookingControllerProvider);
      expect(state.phase, RidePlanningPhase.paymentPending);
      expect(state.isSearchingForDriver, isFalse);
      expect(state.cardPaymentUiState, CardPaymentUiState.requiresAction);
    });

    test('M/N PaymentSheet cancel and failed keep quoted booking', () async {
      final quoted = const CreateBookingResult(
        booking: BookingEntity(
          id: 'b-card',
          status: 'quoted',
          paymentMethodCode: 'card',
        ),
        payment: BookingPaymentEntity(
          paymentMethod: 'card',
          status: 'requires_payment_method',
          clientSecret: 'pi_1_secret_x',
        ),
      );
      final repo = _FakeStripeRepo()..createResult = quoted;
      final stripe = _FakeStripe()..outcome = StripeSheetOutcome.canceled;
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_readyState(paymentCode: 'card'));
      await c.confirmBooking();
      var state = container.read(rideBookingControllerProvider);
      expect(state.bookingId, 'b-card');
      expect(state.bookingStatus, 'quoted');
      expect(state.phase, RidePlanningPhase.paymentPending);
      expect(state.isSearchingForDriver, isFalse);
      expect(repo.createCalls, 1);

      stripe.outcome = StripeSheetOutcome.failed;
      repo.paymentQueue.add(
        const BookingPaymentEntity(
          paymentMethod: 'card',
          status: 'failed',
          clientSecret: 'pi_1_secret_x',
        ),
      );
      await c.retryCardPayment();
      state = container.read(rideBookingControllerProvider);
      expect(state.phase, RidePlanningPhase.paymentPending);
      expect(state.isSearchingForDriver, isFalse);
      expect(repo.createCalls, 1);
    });

    test('O retry uses existing booking and PaymentIntent', () async {
      final repo = _FakeStripeRepo()
        ..active = const BookingEntity(
          id: 'b-card',
          status: 'quoted',
          paymentMethodCode: 'card',
        )
        ..refreshed = const BookingEntity(
          id: 'b-card',
          status: 'searching',
          paymentMethodCode: 'card',
        )
        ..paymentQueue.addAll(const [
          BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'requires_payment_method',
            clientSecret: 'pi_same_secret',
          ),
          BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'authorized',
          ),
        ]);
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        const RideBookingState(
          bookingId: 'b-card',
          bookingStatus: 'quoted',
          phase: RidePlanningPhase.paymentPending,
          paymentMethodCode: 'card',
          paymentClientSecret: 'pi_same_secret',
          cardPaymentUiState: CardPaymentUiState.requiresAction,
        ),
      );
      await c.retryCardPayment();
      expect(repo.createCalls, 0);
      expect(stripe.lastClientSecret, 'pi_same_secret');
      expect(
        container.read(rideBookingControllerProvider).bookingId,
        'b-card',
      );
    });

    test('P app restart restores quoted payment-pending booking', () async {
      final repo = _FakeStripeRepo()
        ..active = const BookingEntity(
          id: 'b-card',
          status: 'quoted',
          paymentMethodCode: 'card',
          pickupAddress: 'Dhanmondi',
          pickupLatitude: 23.75,
          pickupLongitude: 90.38,
        )
        ..paymentQueue.add(
          const BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'requires_payment_method',
            clientSecret: 'pi_restore_secret',
          ),
        );
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      final restored = await c.restoreActiveBooking(navigate: false);
      expect(restored, isTrue);
      final state = container.read(rideBookingControllerProvider);
      expect(state.bookingId, 'b-card');
      expect(state.phase, RidePlanningPhase.paymentPending);
      expect(state.isSearchingForDriver, isFalse);
      expect(state.hasActiveBooking, isTrue);
      expect(state.canRetryCardPayment, isTrue);
      expect(state.paymentClientSecret, 'pi_restore_secret');
    });

    test('D publishable key from backend initializes Stripe once per key', () async {
      final repo = _FakeStripeRepo();
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_readyState(paymentCode: 'card'));
      repo.createResult = const CreateBookingResult(
        booking: BookingEntity(
          id: 'b-card',
          status: 'quoted',
          paymentMethodCode: 'card',
        ),
        payment: BookingPaymentEntity(
          paymentMethod: 'card',
          status: 'requires_payment_method',
          clientSecret: 'pi_1_secret_x',
        ),
      );
      stripe.outcome = StripeSheetOutcome.canceled;
      await c.confirmBooking();
      expect(stripe.lastPublishableKey, 'pk_test_backend');
      expect(stripe.initCount, 1);
    });
  });

  group('Stripe Phase C source and payload guards', () {
    test('E no hardcoded Stripe secret or publishable key in lib', () {
      final lib = Directory('lib');
      final hits = <String>[];
      for (final file in lib.listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        final text = file.readAsStringSync();
        if (text.contains('sk_live') ||
            text.contains('sk_test') ||
            RegExp(r"pk_(test|live)_[A-Za-z0-9]{8,}").hasMatch(text)) {
          hits.add(file.path);
        }
      }
      expect(hits, isEmpty, reason: hits.join(', '));
    });

    test('G create payload never includes client amounts', () {
      final body = BookingCreateRequest.body(
        serviceCategoryId: 'svc1',
        pickup: const LatLngWaypoint(latitude: 1, longitude: 2),
        dropoff: const LatLngWaypoint(latitude: 3, longitude: 4),
        paymentMethodCode: 'card',
      );
      expect(body['paymentMethodCode'], 'card');
      expect(body.containsKey('amount'), isFalse);
      expect(body.containsKey('fare'), isFalse);
      expect(body.containsKey('finalFare'), isFalse);
      expect(body.containsKey('paymentMethodId'), isFalse);
    });

    test('R no capture/transfer/commission APIs in passenger booking flow', () {
      final files = [
        File(
          'lib/features/ride_booking/presentation/providers/ride_booking_controller.dart',
        ),
        File(
          'lib/features/ride_booking/data/datasources/passenger_ride_remote_datasource.dart',
        ),
        File('lib/core/constants/passenger_api_paths.dart'),
      ];
      for (final file in files) {
        final text = file.readAsStringSync();
        expect(text.contains('/capture'), isFalse);
        expect(text.toLowerCase().contains('commission'), isFalse);
        expect(text.toLowerCase().contains('driver transfer'), isFalse);
      }
    });

    test('stripe error codes map to user-safe copy without cash fallback', () {
      expect(
        PassengerApiErrorMapper.userMessageForCode('CARD_PAYMENTS_NOT_ENABLED'),
        CardBookingPayment.unavailableMessage,
      );
      expect(
        PassengerApiErrorMapper.userMessageForCode('STRIPE_NOT_CONFIGURED'),
        isNot(contains('cash')),
      );
    });

    test('booking screens no longer fall back to Cash', () {
      for (final path in [
        'lib/features/ride_booking/presentation/screens/ride_selection_screen.dart',
        'lib/features/ride_booking/presentation/screens/confirm_pickup_screen.dart',
        'lib/features/payment/presentation/widgets/payment_method_modal.dart',
        'lib/features/ride_booking/presentation/widgets/payment_method_tile.dart',
        'lib/features/rentals/presentation/widgets/rental_payment_method_card.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source.contains("'Cash'"), isFalse, reason: path);
        expect(source.contains('"Cash"'), isFalse, reason: path);
      }
    });
  });
}
