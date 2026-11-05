import 'dart:async';

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
import 'package:rydu_user/features/ride_booking/data/services/stripe_payment_gateway.dart';
import 'package:rydu_user/features/ride_booking/domain/meter_checkout_launcher.dart';
import 'package:rydu_user/features/ride_booking/domain/repositories/ride_booking_repository.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';
import 'package:rydu_user/features/ride_booking/presentation/widgets/meter_payment_card.dart';
import 'package:rydu_user/features/ride_booking/presentation/widgets/ride_option_card.dart';
import 'package:rydu_user/features/ride_history/presentation/widgets/ride_history_card.dart';
import 'package:rydu_user/features/ride_tracking/presentation/widgets/soft_meter_panel.dart';

class _FakeStripe implements StripePaymentGateway {
  int presentCount = 0;
  int initCount = 0;
  String? lastClientSecret;
  String? lastPublishableKey;
  StripeSheetOutcome outcome = StripeSheetOutcome.completed;

  @override
  Future<bool> initialize({required String publishableKey}) async {
    initCount++;
    lastPublishableKey = publishableKey;
    return true;
  }

  @override
  Future<StripeSheetOutcome> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    presentCount++;
    lastClientSecret = clientSecret;
    return outcome;
  }
}

class _FakeCheckoutLauncher implements MeterCheckoutLauncher {
  final opened = <Uri>[];
  bool result = true;

  @override
  Future<bool> openHostedCheckout(Uri uri) async {
    opened.add(uri);
    return result;
  }
}

class _PaymentFakeRepo implements RideBookingRepository {
  MeterPaymentRecord? payment;
  MeterPaymentRecord? unpaid;
  MeterPaymentRecord? receipt;
  MeterPaymentRecord? checkoutRecord;
  String? checkoutClientSecret;
  String? checkoutPublishableKey;
  CreateBookingResult? createResult;
  final checkoutIds = <String>[];
  Completer<void>? checkoutGate;
  int paymentGets = 0;
  List<MeterPaymentRecord?>? paymentQueue;
  PassengerApiException? paymentErrorOnce;
  int unpaidGets = 0;
  int createCalls = 0;
  int paymentIntentGets = 0;
  String? lastPaymentMethodCode;
  Map<String, dynamic>? lastCreateBody;
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
  Future<List<PaymentMethodEntity>> paymentMethods() async => const [
    PaymentMethodEntity(code: 'card', label: 'Card', isDefault: true),
  ];

  @override
  Future<PaymentConfigEntity> paymentConfig() async =>
      const PaymentConfigEntity(
        stripeEnabled: true,
        cardEnabled: true,
        publishableKey: 'pk_test_backend',
      );

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
    lastCreateBody = {
      'serviceCategoryId': serviceCategoryId,
      'paymentMethodCode': paymentMethodCode,
      'idempotencyKey': idempotencyKey,
    };
    final result = createResult;
    if (result == null) throw UnimplementedError();
    return result;
  }

  @override
  Future<BookingPaymentEntity> bookingPayment(String bookingId) async {
    paymentIntentGets++;
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
  Future<PassengerMeterSnapshot> bookingMeter(String bookingId) async =>
      PassengerMeterSnapshot.empty;

  @override
  Future<MeterPaymentRecord?> meterPayment(String bookingId) async {
    paymentGets++;
    final error = paymentErrorOnce;
    if (error != null) {
      paymentErrorOnce = null;
      throw error;
    }
    final queue = paymentQueue;
    if (queue != null && queue.isNotEmpty) {
      return queue.removeAt(0);
    }
    return payment;
  }

  @override
  Future<MeterPaymentIntentResult> createMeterPaymentIntent(
    String bookingId,
  ) async {
    checkoutIds.add(bookingId);
    final gate = checkoutGate;
    if (gate != null) await gate.future;
    return MeterPaymentIntentResult(
      record: checkoutRecord ?? payment,
      clientSecret: checkoutClientSecret,
      publishableKey: checkoutPublishableKey,
    );
  }

  @override
  Future<MeterPaymentRecord?> meterPaymentReceipt(String bookingId) async =>
      receipt;

  @override
  Future<MeterPaymentRecord?> unpaidMeterPayment() async {
    unpaidGets++;
    return unpaid;
  }
}

MeterPaymentRecord _verifiedPaid([
  String bookingId = '7ee40579-449b-46ce-b1f4-191604d79c71',
]) {
  return MeterPaymentRecord(
    bookingId: bookingId,
    rideStatus: 'completed',
    paymentStatus: MeterPaymentStatus.paid,
    paymentStatusRaw: 'paid',
    paymentRequired: false,
    finalFareCents: 480,
    currency: 'USD',
    receiptAvailable: true,
    testMode: true,
    productionCharge: false,
    paymentVersion: 4,
    paymentMode: 'meter',
  );
}

MeterPaymentRecord _pending({
  String bookingId = 'b-meter',
  int version = 1,
  int cents = 1875,
}) {
  return MeterPaymentRecord(
    bookingId: bookingId,
    rideStatus: 'completed',
    paymentStatus: MeterPaymentStatus.paymentPending,
    paymentStatusRaw: 'payment_pending',
    paymentRequired: true,
    paymentMode: 'meter',
    finalFareCents: cents,
    currency: 'USD',
    meterSessionId: 'ms-1',
    testMode: true,
    fareClassification: 'soft_meter',
    paymentVersion: version,
    productionCharge: false,
  );
}

ProviderContainer _container({
  required _PaymentFakeRepo repo,
  _FakeCheckoutLauncher? launcher,
  _FakeStripe? stripe,
}) {
  final goRouter = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(path: RouteNames.home, builder: (_, _) => const SizedBox()),
      GoRoute(path: RouteNames.activity, builder: (_, _) => const SizedBox()),
      GoRoute(
        path: RouteNames.findingDriver,
        builder: (_, _) => const SizedBox(),
      ),
      GoRoute(
        path: RouteNames.meterPayment,
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
      meterCheckoutLauncherProvider.overrideWithValue(
        launcher ?? _FakeCheckoutLauncher(),
      ),
      if (stripe != null)
        stripePaymentGatewayProvider.overrideWithValue(stripe),
      paymentPollDelayProvider.overrideWithValue((_) async {}),
    ],
  );
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

RideBookingState _readyMeteredQuoteState() {
  const vehicle = RideOptionEntity(
    id: 'svc1',
    name: 'Economy',
    category: 'recommended',
    time: '5 min',
    description: 'Affordable',
    price: 'USD 12.00',
    billingMode: BookingBillingMode.meteredPostTrip,
    paymentRequiredBeforeDispatch: false,
    paymentRequiredAfterCompletion: true,
    fareClassification: 'test_only_unapproved_tariff',
  );
  return RideBookingState(
    pickupPlace: _pickup,
    dropoffPlace: _dropoff,
    selectedDestination: const RideDestinationEntity(
      id: 'd1',
      name: 'Mirpur',
      address: 'Mirpur',
      distance: '',
    ),
    selectedVehicle: vehicle,
    selectedVehicleId: 'svc1',
    billingMode: BookingBillingMode.meteredPostTrip,
    paymentRequiredBeforeDispatch: false,
    paymentRequiredAfterCompletion: true,
    fareClassification: 'test_only_unapproved_tariff',
    isPickupResolved: true,
    pickupSource: PickupSource.currentLocation,
    paymentMethod: CardBookingPayment.label,
    paymentMethodCode: CardBookingPayment.code,
    paymentMethods: const [
      PaymentMethodEntity(code: 'card', label: 'Card', isDefault: true),
    ],
    phase: RidePlanningPhase.quoteLoaded,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Meter payment parser', () {
    test('reads supported meterPayment fields', () {
      final parsed = RidePlanningParsers.meterPayment({
        'bookingId': 'b-meter',
        'rideStatus': 'completed',
        'paymentStatus': 'payment_pending',
        'paymentRequired': true,
        'paymentMode': 'meter',
        'finalFareCents': 1875,
        'currency': 'USD',
        'meterSessionId': 'ms-1',
        'receiptAvailable': false,
        'hostedUrl': 'https://checkout.stripe.com/c/pay/cs_test_1',
        'testMode': true,
        'fareClassification': 'soft_meter',
        'paymentVersion': 3,
        'productionCharge': false,
      });
      expect(parsed?.bookingId, 'b-meter');
      expect(parsed?.paymentStatus, MeterPaymentStatus.paymentPending);
      expect(parsed?.paymentRequired, isTrue);
      expect(parsed?.finalFareCents, 1875);
      expect(parsed?.formattedFinalFare, 'USD 18.75');
      expect(parsed?.testMode, isTrue);
      expect(parsed?.productionCharge, isFalse);
      expect(parsed?.needsPayNow, isTrue);
    });

    test('exact backend payment-intent JSON uses paymentIntentClientSecret', () {
      const payload = {
        'bookingId': 'b-meter',
        'paymentIntentClientSecret': 'pi_test_secret_exact',
        'paymentIntentId': 'pi_exact',
        'publishableKey': 'pk_test_exact',
        'finalFareCents': 1875,
        'currency': 'USD',
        'paymentStatus': 'payment_pending',
        'testMode': true,
        'paymentVersion': 2,
        'productionCharge': false,
      };
      final flat = RidePlanningParsers.meterPaymentIntent(payload);
      final wrapped = RidePlanningParsers.meterPaymentIntent({
        'success': true,
        'data': payload,
      });
      for (final session in [flat, wrapped]) {
        expect(session.clientSecret, 'pi_test_secret_exact');
        expect(session.paymentIntentId, 'pi_exact');
        expect(session.publishableKey, 'pk_test_exact');
        expect(session.record?.bookingId, 'b-meter');
        expect(session.record?.finalFareCents, 1875);
        expect(session.record?.formattedFinalFare, 'USD 18.75');
        expect(session.record?.currencyCode, 'USD');
        expect(session.record?.paymentStatus, MeterPaymentStatus.paymentPending);
        expect(session.record?.testMode, isTrue);
        expect(session.record?.paymentVersion, 2);
        expect(session.record?.productionCharge, isFalse);
        expect(session.record?.needsPayNow, isTrue);
        expect(session.hasClientSecret, isTrue);
      }
    });

    test('paymentIntentClientSecret wins over clientSecret alias', () {
      final session = RidePlanningParsers.meterPaymentIntent({
        'bookingId': 'b-meter',
        'paymentStatus': 'payment_pending',
        'finalFareCents': 100,
        'currency': 'USD',
        'paymentIntentClientSecret': 'pi_authoritative',
        'clientSecret': 'pi_alias',
        'publishableKey': 'pk_test_key',
      });
      expect(session.clientSecret, 'pi_authoritative');
      expect(session.publishableKey, 'pk_test_key');
    });

    test('null paymentIntentClientSecret does not invent a secret', () {
      final session = RidePlanningParsers.meterPaymentIntent({
        'success': true,
        'data': {
          'bookingId': 'b-meter',
          'paymentIntentClientSecret': null,
          'paymentIntentId': 'pi_exact',
          'publishableKey': 'pk_test_exact',
          'finalFareCents': 1875,
          'currency': 'USD',
          'paymentStatus': 'paid',
          'testMode': true,
          'paymentVersion': 3,
          'productionCharge': false,
        },
      });
      expect(session.hasClientSecret, isFalse);
      expect(session.clientSecret, isNull);
      expect(session.record?.isPaid, isTrue);
      expect(session.publishableKey, 'pk_test_exact');
    });

    test('payment intent response keeps client secret off the fare record', () {
      final session = RidePlanningParsers.meterPaymentIntent({
        'bookingId': 'b-meter',
        'paymentStatus': 'payment_pending',
        'paymentRequired': true,
        'paymentMode': 'meter',
        'finalFareCents': 1875,
        'currency': 'USD',
        'clientSecret': 'pi_test_secret_meter',
        'paymentIntentId': 'pi_123',
        'testMode': true,
        'hostedUrl': 'https://checkout.stripe.com/c/pay/cs_test_1',
      });
      expect(session.clientSecret, 'pi_test_secret_meter');
      expect(session.paymentIntentId, 'pi_123');
      expect(session.record?.formattedFinalFare, 'USD 18.75');
      expect(session.record?.needsPayNow, isTrue);
      expect(session.hasClientSecret, isTrue);
    });

    test('nested payment client secret is accepted', () {
      final session = RidePlanningParsers.meterPaymentIntent({
        'meterPayment': {
          'bookingId': 'b-meter',
          'paymentStatus': 'payment_pending',
          'paymentRequired': true,
          'paymentMode': 'meter',
          'finalFareCents': 2100,
          'currency': 'USD',
        },
        'payment': {
          'client_secret': 'pi_nested_secret',
          'paymentIntentId': 'pi_nested',
        },
      });
      expect(session.clientSecret, 'pi_nested_secret');
      expect(session.paymentIntentId, 'pi_nested');
      expect(session.record?.finalFareCents, 2100);
    });

    test('nested meterPayment on booking is optional for historical rides', () {
      final booking = RidePlanningParsers.booking({
        'id': 'old-1',
        'status': 'completed',
        'finalFare': 12.5,
        'currency': 'BDT',
      });
      expect(booking?.meterPayment, isNull);
      expect(booking?.isMeteredBooking, isFalse);
      expect(booking?.passengerFacingFare, 'BDT 12.50');
    });

    test('missing optional payment fields stay null', () {
      final parsed = RidePlanningParsers.meterPayment({
        'bookingId': 'b-meter',
        'paymentRequired': true,
        'paymentMode': 'meter',
      });
      expect(parsed?.finalFareCents, isNull);
      expect(parsed?.hostedUrl, isNull);
      expect(parsed?.receiptUrl, isNull);
      expect(parsed?.paidAt, isNull);
      expect(parsed?.flagDropCents, isNull);
    });

    test('status variants map to passenger labels', () {
      expect(
        MeterPaymentStatusParsing.fromRaw('checkout_open'),
        MeterPaymentStatus.checkoutOpen,
      );
      expect(
        MeterPaymentStatusParsing.fromRaw('payment_failed'),
        MeterPaymentStatus.paymentFailed,
      );
      expect(MeterPaymentStatusParsing.fromRaw('paid'), MeterPaymentStatus.paid);
      expect(
        MeterPaymentStatusParsing.fromRaw('refunded'),
        MeterPaymentStatus.refunded,
      );
      expect(
        MeterPaymentStatusParsing.fromRaw('expired'),
        MeterPaymentStatus.paymentFailed,
      );
      expect(
        MeterPaymentStatusParsing.fromRaw('meter_unresolved'),
        MeterPaymentStatus.meterUnresolved,
      );
    });

    test('parses metered_post_trip booking without payment envelope', () {
      final result = RidePlanningParsers.createBookingResult({
        'id': 'b-meter',
        'status': 'searching',
        'paymentStatus': 'pending',
        'paymentMethodCode': 'card',
        'billingMode': 'metered_post_trip',
        'paymentRequiredBeforeDispatch': false,
        'paymentRequiredAfterCompletion': true,
        'fareClassification': 'test_only_unapproved_tariff',
      });
      expect(result, isNotNull);
      expect(result!.payment, isNull);
      expect(result.booking.status, 'searching');
      expect(result.booking.billingMode, BookingBillingMode.meteredPostTrip);
      expect(result.booking.paymentRequiredBeforeDispatch, isFalse);
      expect(result.booking.paymentRequiredAfterCompletion, isTrue);
      expect(result.booking.skipsUpfrontCardAuthorization, isTrue);
      expect(result.booking.paymentStatus, 'pending');
    });

    test('historical null billing mode stays compatible', () {
      final booking = RidePlanningParsers.booking({
        'id': 'legacy',
        'status': 'completed',
        'finalFare': 10,
        'currency': 'USD',
      });
      expect(booking?.billingMode, BookingBillingMode.unknown);
      expect(booking?.skipsUpfrontCardAuthorization, isFalse);
      expect(booking?.passengerFacingFare, 'USD 10.00');
    });

    test('quote billingMode does not override booking create', () {
      final booking = RidePlanningParsers.booking({
        'id': 'b-scheduled',
        'status': 'quoted',
        'billingMode': 'quoted_prepay',
        'paymentRequiredBeforeDispatch': true,
        'paymentRequiredAfterCompletion': false,
      });
      expect(booking?.billingMode, BookingBillingMode.quotedPrepay);
      expect(booking?.skipsUpfrontCardAuthorization, isFalse);
    });
  });

  group('metered_post_trip skips upfront PaymentSheet', () {
    test('confirmBooking proceeds to searching without PaymentSheet', () async {
      final repo = _PaymentFakeRepo()
        ..createResult = const CreateBookingResult(
          booking: BookingEntity(
            id: 'b-meter',
            status: 'searching',
            paymentMethodCode: 'card',
            paymentStatus: 'pending',
            billingMode: BookingBillingMode.meteredPostTrip,
            paymentRequiredBeforeDispatch: false,
            paymentRequiredAfterCompletion: true,
            fareClassification: 'test_only_unapproved_tariff',
          ),
        );
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(_readyMeteredQuoteState());

      await c.confirmBooking();

      final state = container.read(rideBookingControllerProvider);
      expect(repo.createCalls, 1);
      expect(repo.lastPaymentMethodCode, 'card');
      expect(repo.lastCreateBody!.containsKey('billingMode'), isFalse);
      expect(repo.lastCreateBody!.containsKey('amount'), isFalse);
      expect(stripe.presentCount, 0);
      expect(repo.paymentIntentGets, 0);
      expect(state.phase, RidePlanningPhase.bookingSearching);
      expect(state.isSearchingForDriver, isTrue);
      expect(state.isPaymentPending, isFalse);
      expect(state.billingMode, BookingBillingMode.meteredPostTrip);
      expect(state.paymentClientSecret, isNull);
      expect(state.usesSoftMeterUi, isTrue);
    });

    test('booking create quoted_prepay overrides prior metered quote', () async {
      final repo = _PaymentFakeRepo()
        ..createResult = const CreateBookingResult(
          booking: BookingEntity(
            id: 'b-quoted',
            status: 'quoted',
            paymentMethodCode: 'card',
            billingMode: BookingBillingMode.quotedPrepay,
            paymentRequiredBeforeDispatch: true,
            paymentRequiredAfterCompletion: false,
          ),
          payment: BookingPaymentEntity(
            paymentMethod: 'card',
            status: 'requires_payment_method',
            clientSecret: 'pi_secret',
          ),
        );
      final stripe = _FakeStripe()..outcome = StripeSheetOutcome.canceled;
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      // Seeded as metered quote, but create returns quoted_prepay.
      c.debugSeedState(_readyMeteredQuoteState());

      await c.confirmBooking();

      final state = container.read(rideBookingControllerProvider);
      expect(stripe.presentCount, 1);
      expect(stripe.initCount, greaterThan(0));
      expect(state.phase, RidePlanningPhase.paymentPending);
      expect(state.isSearchingForDriver, isFalse);
      expect(state.billingMode, BookingBillingMode.quotedPrepay);
      expect(state.usesSoftMeterUi, isFalse);
    });

    test('meter_unresolved never opens Checkout or shows Paid', () async {
      final unresolved = const MeterPaymentRecord(
        bookingId: 'b-unresolved',
        paymentStatus: MeterPaymentStatus.meterUnresolved,
        paymentRequired: false,
        paymentMode: 'meter',
      );
      final repo = _PaymentFakeRepo()..payment = unresolved;
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        const RideBookingState(
          bookingId: 'b-unresolved',
          phase: RidePlanningPhase.completed,
          billingMode: BookingBillingMode.meteredPostTrip,
          meterPayment: MeterPaymentRecord(
            bookingId: 'b-unresolved',
            paymentStatus: MeterPaymentStatus.meterUnresolved,
            paymentRequired: false,
            paymentMode: 'meter',
          ),
        ),
      );

      expect(unresolved.needsPayNow, isFalse);
      expect(unresolved.isPaid, isFalse);
      expect(await c.startMeterCheckout(bookingId: 'b-unresolved'), isFalse);
      expect(repo.checkoutIds, isEmpty);
      expect(
        container.read(rideBookingControllerProvider).meterPaymentError,
        SoftMeterPaymentCopy.unresolved,
      );
    });

    test('Rentals keep quoted Soft Meter UI off', () {
      const rentals = RideBookingState(
        selectedRideType: RideBookingTypeIds.rentals,
        billingMode: BookingBillingMode.meteredPostTrip,
      );
      expect(rentals.usesSoftMeterUi, isFalse);
    });
  });

  group('Checkout URL safety', () {
    test('only backend https URLs are accepted', () {
      expect(
        MeterCheckoutUrls.parseSafeHttps(
          'https://checkout.stripe.com/c/pay/cs_test_1',
        ),
        isNotNull,
      );
      expect(MeterCheckoutUrls.parseSafeHttps('http://example.com'), isNull);
      expect(MeterCheckoutUrls.parseSafeHttps('javascript:alert(1)'), isNull);
      expect(MeterCheckoutUrls.parseSafeHttps(''), isNull);
    });
  });

  group('RideBookingState Soft Meter payment UI', () {
    test('on-demand hides quoted prices; rentals keep them', () {
      const onDemand = RideBookingState(
        selectedRideType: RideBookingTypeIds.ride,
        estimatedFare: 'USD 25.00',
      );
      const rentals = RideBookingState(
        selectedRideType: RideBookingTypeIds.rentals,
        estimatedFare: 'USD 40.00',
      );
      expect(onDemand.usesSoftMeterUi, isTrue);
      expect(rentals.usesSoftMeterUi, isFalse);
    });

    test('quote authorization fields remain on state for existing clients', () {
      const state = RideBookingState(
        estimatedFare: 'USD 25.00',
        phase: RidePlanningPhase.paymentPending,
        paymentClientSecret: 'pi_test_secret',
      );
      expect(state.usesSoftMeterUi, isTrue);
      expect(state.estimatedFare, 'USD 25.00');
      expect(state.isPaymentPending, isTrue);
      expect(state.paymentClientSecret, 'pi_test_secret');
    });
  });

  group('Meter payment controller', () {
    test('Pay Now opens in-app PaymentSheet with backend client secret', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending()
        ..checkoutRecord = _pending()
        ..checkoutClientSecret = 'pi_test_secret_meter';
      final launcher = _FakeCheckoutLauncher();
      final stripe = _FakeStripe();
      final container = _container(
        repo: repo,
        launcher: launcher,
        stripe: stripe,
      );
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );

      final ok = await c.startMeterCheckout(bookingId: 'b-meter');
      expect(ok, isTrue);
      expect(repo.checkoutIds, ['b-meter']);
      expect(launcher.opened, isEmpty);
      expect(stripe.presentCount, 1);
      expect(stripe.lastClientSecret, 'pi_test_secret_meter');
      expect(stripe.initCount, greaterThan(0));
      final state = container.read(rideBookingControllerProvider);
      expect(state.meterPayment?.isPaid, isFalse);
      expect(state.meterPayment?.formattedFinalFare, 'USD 18.75');
      expect(state.paymentClientSecret, isNull);
    });

    test('Pay Now initializes Stripe with the intent publishableKey', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending()
        ..checkoutRecord = _pending()
        ..checkoutClientSecret = 'pi_test_secret_exact'
        ..checkoutPublishableKey = 'pk_test_exact';
      final launcher = _FakeCheckoutLauncher();
      final stripe = _FakeStripe();
      final container = _container(
        repo: repo,
        launcher: launcher,
        stripe: stripe,
      );
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );

      expect(await c.startMeterCheckout(bookingId: 'b-meter'), isTrue);
      expect(launcher.opened, isEmpty);
      expect(stripe.lastPublishableKey, 'pk_test_exact');
      expect(stripe.lastClientSecret, 'pi_test_secret_exact');
      expect(stripe.presentCount, 1);
      expect(
        container.read(rideBookingControllerProvider).paymentClientSecret,
        isNull,
      );
    });

    test('null client secret refreshes status and does not open PaymentSheet', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending()
        ..checkoutRecord = _pending()
        ..checkoutClientSecret = null;
      final launcher = _FakeCheckoutLauncher();
      final stripe = _FakeStripe();
      final container = _container(
        repo: repo,
        launcher: launcher,
        stripe: stripe,
      );
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );

      expect(await c.startMeterCheckout(bookingId: 'b-meter'), isFalse);
      expect(stripe.presentCount, 0);
      expect(launcher.opened, isEmpty);
      expect(repo.paymentGets, greaterThan(0));
      final state = container.read(rideBookingControllerProvider);
      expect(state.meterPayment?.isPaid, isFalse);
      expect(state.meterPayment?.needsPayNow, isTrue);
    });

    test('pk_live intent key does not open PaymentSheet', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending()
        ..checkoutRecord = _pending().copyWith(productionCharge: true)
        ..checkoutClientSecret = 'pi_live_secret'
        ..checkoutPublishableKey = 'pk_live_disabled';
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );
      expect(await c.startMeterCheckout(bookingId: 'b-meter'), isFalse);
      expect(stripe.presentCount, 0);
      expect(stripe.initCount, 0);
    });

    test('null client secret accepts backend Paid without opening PaymentSheet', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending().copyWith(
          paymentStatus: MeterPaymentStatus.paid,
          paymentRequired: false,
          paymentVersion: 4,
        )
        ..checkoutRecord = _pending()
        ..checkoutClientSecret = null;
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );

      expect(await c.startMeterCheckout(bookingId: 'b-meter'), isTrue);
      expect(stripe.presentCount, 0);
      expect(
        container.read(rideBookingControllerProvider).meterPayment?.isPaid,
        isTrue,
      );
    });

    test('duplicate Pay Now taps are ignored while checkout is in flight', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending()
        ..checkoutRecord = _pending()
        ..checkoutClientSecret = 'pi_test_secret_meter'
        ..checkoutGate = Completer<void>();
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );

      final first = c.startMeterCheckout(bookingId: 'b-meter');
      final second = c.startMeterCheckout(bookingId: 'b-meter');
      await Future<void>.delayed(Duration.zero);
      expect(repo.checkoutIds, ['b-meter']);
      repo.checkoutGate!.complete();
      expect(await first, isTrue);
      expect(await second, isFalse);
      expect(stripe.presentCount, 1);
    });

    test('PaymentSheet success waits for backend confirmation', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending()
        ..checkoutRecord = _pending()
        ..checkoutClientSecret = 'pi_test_secret_meter';
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );
      await c.startMeterCheckout(bookingId: 'b-meter');
      expect(stripe.presentCount, 1);
      expect(stripe.outcome, StripeSheetOutcome.completed);
      expect(
        container.read(rideBookingControllerProvider).meterPayment?.isPaid,
        isFalse,
      );
      final state = container.read(rideBookingControllerProvider);
      expect(state.meterPayment?.needsPayNow, isTrue);
      expect(state.meterPaymentConfirming, isTrue);
      expect(state.canOfferMeterPayNow, isFalse);
      expect(repo.paymentGets, 5);
      expect(repo.checkoutIds, ['b-meter']);
    });

    test('PaymentSheet success applies the verified paid meter response', () async {
      const bookingId = '7ee40579-449b-46ce-b1f4-191604d79c71';
      final paid = _verifiedPaid(bookingId);
      final repo = _PaymentFakeRepo()
        ..payment = paid
        ..checkoutRecord = _pending(bookingId: bookingId)
        ..checkoutClientSecret = 'pi_test_secret_meter';
      final launcher = _FakeCheckoutLauncher();
      final stripe = _FakeStripe();
      final container = _container(
        repo: repo,
        launcher: launcher,
        stripe: stripe,
      );
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: bookingId,
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(bookingId: bookingId),
          unpaidMeterPayment: _pending(bookingId: bookingId),
        ),
      );

      expect(await c.startMeterCheckout(bookingId: bookingId), isTrue);
      final state = container.read(rideBookingControllerProvider);
      expect(stripe.presentCount, 1);
      expect(launcher.opened, isEmpty);
      expect(repo.checkoutIds, [bookingId]);
      expect(repo.paymentGets, 1);
      expect(state.meterPayment?.isPaid, isTrue);
      expect(state.meterPayment?.paymentRequired, isFalse);
      expect(state.meterPayment?.finalFareCents, 480);
      expect(state.meterPayment?.formattedFinalFare, 'USD 4.80');
      expect(state.meterPayment?.receiptAvailable, isTrue);
      expect(state.meterPayment?.canShowPaidReceipt, isTrue);
      expect(state.meterPayment?.needsPayNow, isFalse);
      expect(state.canOfferMeterPayNow, isFalse);
      expect(state.meterPaymentConfirming, isFalse);
      expect(state.shouldShowUnpaidMeterReminder, isFalse);
      expect(state.unpaidMeterPayment, isNull);
      expect(state.paymentClientSecret, isNull);
    });

    test('delayed paid status retries then hides Pay Now', () async {
      const bookingId = '7ee40579-449b-46ce-b1f4-191604d79c71';
      final paid = _verifiedPaid(bookingId);
      final repo = _PaymentFakeRepo()
        ..checkoutRecord = _pending(bookingId: bookingId)
        ..checkoutClientSecret = 'pi_test_secret_meter'
        ..paymentQueue = [
          _pending(bookingId: bookingId),
          _pending(bookingId: bookingId),
          paid,
        ];
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: bookingId,
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(bookingId: bookingId),
          unpaidMeterPayment: _pending(bookingId: bookingId),
        ),
      );

      expect(await c.startMeterCheckout(bookingId: bookingId), isTrue);
      final state = container.read(rideBookingControllerProvider);
      expect(repo.paymentGets, 3);
      expect(repo.checkoutIds, [bookingId]);
      expect(stripe.presentCount, 1);
      expect(state.meterPayment?.isPaid, isTrue);
      expect(state.canOfferMeterPayNow, isFalse);
      expect(state.meterPaymentConfirming, isFalse);
      expect(state.shouldShowUnpaidMeterReminder, isFalse);
    });

    test('429 Retry-After is waited then paid status is applied', () async {
      const bookingId = '7ee40579-449b-46ce-b1f4-191604d79c71';
      final repo = _PaymentFakeRepo()
        ..payment = _verifiedPaid(bookingId)
        ..checkoutRecord = _pending(bookingId: bookingId)
        ..checkoutClientSecret = 'pi_test_secret_meter'
        ..paymentErrorOnce = const PassengerApiException(
          'slow down',
          statusCode: 429,
          retryAfter: Duration(seconds: 1),
        );
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: bookingId,
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(bookingId: bookingId),
        ),
      );
      expect(await c.startMeterCheckout(bookingId: bookingId), isTrue);
      final state = container.read(rideBookingControllerProvider);
      expect(state.meterPayment?.isPaid, isTrue);
      expect(repo.checkoutIds, [bookingId]);
      expect(stripe.presentCount, 1);
    });

    test('resume refresh replaces a confirming ride with backend Paid', () async {
      const bookingId = '7ee40579-449b-46ce-b1f4-191604d79c71';
      final repo = _PaymentFakeRepo()
        ..payment = _verifiedPaid(bookingId)
        ..unpaid = null;
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: bookingId,
          phase: RidePlanningPhase.completed,
          meterPaymentConfirming: true,
          meterPayment: _pending(bookingId: bookingId),
          unpaidMeterPayment: _pending(bookingId: bookingId),
        ),
      );
      await c.refreshMeterPaymentOnResume();
      final state = container.read(rideBookingControllerProvider);
      expect(state.meterPayment?.isPaid, isTrue);
      expect(state.meterPaymentConfirming, isFalse);
      expect(state.unpaidMeterPayment, isNull);
      expect(state.shouldShowUnpaidMeterReminder, isFalse);
      expect(state.canOfferMeterPayNow, isFalse);
    });

    test('null unpaid recovery clears a stale reminder', () async {
      final repo = _PaymentFakeRepo()..unpaid = null;
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          phase: RidePlanningPhase.initial,
          unpaidMeterPayment: _pending(),
        ),
      );
      await c.recoverUnpaidMeterPayment();
      final state = container.read(rideBookingControllerProvider);
      expect(state.unpaidMeterPayment, isNull);
      expect(state.shouldShowUnpaidMeterReminder, isFalse);
    });

    test('already-paid backend response does not open PaymentSheet', () async {
      final paid = _pending().copyWith(
        paymentStatus: MeterPaymentStatus.paid,
        paymentRequired: false,
      );
      final repo = _PaymentFakeRepo()
        ..payment = paid
        ..checkoutRecord = paid
        ..checkoutClientSecret = 'pi_should_not_open';
      final stripe = _FakeStripe();
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );
      expect(await c.startMeterCheckout(bookingId: 'b-meter'), isTrue);
      expect(stripe.presentCount, 0);
      expect(
        container.read(rideBookingControllerProvider).meterPayment?.isPaid,
        isTrue,
      );
    });

    test('cancelling PaymentSheet leaves the ride unpaid', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending()
        ..checkoutRecord = _pending()
        ..checkoutClientSecret = 'pi_test_secret_meter';
      final stripe = _FakeStripe()..outcome = StripeSheetOutcome.canceled;
      final launcher = _FakeCheckoutLauncher();
      final container = _container(
        repo: repo,
        launcher: launcher,
        stripe: stripe,
      );
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );
      expect(await c.startMeterCheckout(bookingId: 'b-meter'), isFalse);
      expect(launcher.opened, isEmpty);
      final state = container.read(rideBookingControllerProvider);
      expect(state.meterPayment?.isPaid, isFalse);
      expect(state.meterPayment?.needsPayNow, isTrue);
      expect(state.meterPaymentError, contains('cancelled'));
    });

    test('payment failure can be retried with a new PaymentSheet', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending().copyWith(
          paymentStatus: MeterPaymentStatus.paymentFailed,
        )
        ..checkoutRecord = _pending()
        ..checkoutClientSecret = 'pi_test_secret_retry';
      final stripe = _FakeStripe()..outcome = StripeSheetOutcome.failed;
      final container = _container(repo: repo, stripe: stripe);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: repo.payment,
        ),
      );
      expect(await c.startMeterCheckout(bookingId: 'b-meter'), isFalse);
      expect(
        container.read(rideBookingControllerProvider).meterPayment?.isPaid,
        isFalse,
      );
      stripe.outcome = StripeSheetOutcome.completed;
      expect(await c.startMeterCheckout(bookingId: 'b-meter'), isTrue);
      expect(stripe.presentCount, 2);
      expect(stripe.lastClientSecret, 'pi_test_secret_retry');
      expect(
        container.read(rideBookingControllerProvider).meterPayment?.isPaid,
        isFalse,
      );
    });

    test('webhook-confirmed Paid updates after REST/socket', () async {
      final repo = _PaymentFakeRepo()..payment = _pending();
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );
      c.debugHandleMeterPaymentEvent({
        'bookingId': 'b-meter',
        'paymentStatus': 'paid',
        'paymentRequired': false,
        'paymentMode': 'meter',
        'finalFareCents': 1875,
        'currency': 'USD',
        'paymentVersion': 4,
        'receiptAvailable': true,
        'testMode': true,
        'productionCharge': false,
      });
      final state = container.read(rideBookingControllerProvider);
      expect(state.meterPayment?.isPaid, isTrue);
      expect(state.meterPayment?.needsPayNow, isFalse);
      expect(state.unpaidMeterPayment, isNull);
    });

    test('stale paymentVersion cannot overwrite Paid', () {
      final repo = _PaymentFakeRepo();
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(version: 5).copyWith(
            paymentStatus: MeterPaymentStatus.paid,
            paymentRequired: false,
          ),
        ),
      );
      c.debugHandleMeterPaymentEvent({
        'bookingId': 'b-meter',
        'paymentStatus': 'payment_pending',
        'paymentRequired': true,
        'paymentMode': 'meter',
        'finalFareCents': 1875,
        'paymentVersion': 4,
      });
      expect(
        container.read(rideBookingControllerProvider).meterPayment?.isPaid,
        isTrue,
      );
    });

    test('latest unpaid ride is recovered on startup', () async {
      final repo = _PaymentFakeRepo()..unpaid = _pending();
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      await c.recoverUnpaidMeterPayment();
      final state = container.read(rideBookingControllerProvider);
      expect(repo.unpaidGets, 1);
      expect(state.shouldShowUnpaidMeterReminder, isTrue);
      expect(state.unpaidMeterPayment?.formattedFinalFare, 'USD 18.75');
    });

    test('history Pay Now uses the same in-app PaymentSheet', () async {
      final repo = _PaymentFakeRepo()
        ..payment = _pending(bookingId: 'b-older')
        ..checkoutRecord = _pending(bookingId: 'b-older')
        ..checkoutClientSecret = 'pi_test_secret_older';
      final launcher = _FakeCheckoutLauncher();
      final stripe = _FakeStripe();
      final container = _container(
        repo: repo,
        launcher: launcher,
        stripe: stripe,
      );
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          phase: RidePlanningPhase.initial,
          unpaidMeterPayment: _pending(bookingId: 'b-older'),
        ),
      );
      expect(await c.startMeterCheckout(bookingId: 'b-older'), isTrue);
      expect(launcher.opened, isEmpty);
      expect(stripe.presentCount, 1);
      expect(stripe.lastClientSecret, 'pi_test_secret_older');
      expect(repo.checkoutIds, ['b-older']);
    });

    test('payment failure and refund stay backend-authored', () {
      final failed = _pending().copyWith(
        paymentStatus: MeterPaymentStatus.paymentFailed,
      );
      final refunded = _pending().copyWith(
        paymentStatus: MeterPaymentStatus.refunded,
        paymentRequired: false,
      );
      expect(failed.passengerStatusLabel, 'Payment Failed');
      expect(failed.needsPayNow, isTrue);
      expect(refunded.passengerStatusLabel, 'Refunded');
      expect(refunded.needsPayNow, isFalse);
    });

    test('app resume refreshes REST payment status', () async {
      final repo = _PaymentFakeRepo()..payment = _pending()..unpaid = _pending();
      final container = _container(repo: repo);
      addTearDown(container.dispose);
      final c = container.read(rideBookingControllerProvider.notifier);
      c.debugSeedState(
        RideBookingState(
          bookingId: 'b-meter',
          phase: RidePlanningPhase.completed,
          meterPayment: _pending(),
        ),
      );
      await c.refreshMeterPaymentOnResume();
      expect(repo.paymentGets, greaterThan(0));
      expect(repo.unpaidGets, greaterThan(0));
    });
  });

  group('Meter payment UI', () {
    testWidgets('ride option card hides fixed price for metered bookings', (
      tester,
    ) async {
      const option = RideOptionEntity(
        id: 'economy',
        name: 'Economy',
        category: 'recommended',
        time: '5 min',
        description: 'Affordable',
        price: 'USD 12.00',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RideOptionCard(
              option: option,
              isSelected: true,
              hideFixedPrice: true,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('USD 12.00'), findsNothing);
      expect(find.text('Metered'), findsOneWidget);
    });

    testWidgets('non-metered option still shows the quoted price', (
      tester,
    ) async {
      const option = RideOptionEntity(
        id: 'rental',
        name: 'Rental',
        category: 'recommended',
        time: '1 hr',
        description: 'Hourly',
        price: 'USD 40.00',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RideOptionCard(
              option: option,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('USD 40.00'), findsOneWidget);
    });

    testWidgets('live panel never calculates fare and never shows Pay Now', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SoftMeterPanel(
              meter: PassengerMeterSnapshot(
                status: SoftMeterStatus.running,
                totalCents: 1250,
                currency: 'USD',
              ),
            ),
          ),
        ),
      );
      expect(
        find.text(
          'Live meter fare — final amount confirmed when your ride ends.',
        ),
        findsOneWidget,
      );
      expect(find.text('Pay Now'), findsNothing);
      expect(find.text('USD 12.50'), findsOneWidget);
    });

    testWidgets('completed payment card shows pending fare and test mode', (
      tester,
    ) async {
      var payTaps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeterPaymentCard(
              payment: _pending(),
              onPayNow: () => payTaps++,
              onViewHistory: () {},
            ),
          ),
        ),
      );
      expect(find.text('Final metered fare'), findsOneWidget);
      expect(find.text('USD 18.75'), findsOneWidget);
      expect(find.text('Payment Pending'), findsOneWidget);
      expect(
        find.text('Stripe Test Mode — no real money charged.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Pay Now'));
      expect(payTaps, 1);
    });

    testWidgets('history card keeps Pay Now for older unpaid metered rides', (
      tester,
    ) async {
      var payTaps = 0;
      final booking = BookingEntity(
        id: 'old-unpaid',
        status: 'completed',
        pickupAddress: 'Dhanmondi',
        dropoffAddress: 'Mirpur',
        finalFare: 25,
        currency: 'USD',
        meterPayment: _pending(bookingId: 'old-unpaid', cents: 2210),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RideHistoryCard(
              booking: booking,
              onTap: () {},
              onPayNow: () => payTaps++,
            ),
          ),
        ),
      );
      expect(find.text('USD 22.10'), findsOneWidget);
      expect(find.text('USD 25.00'), findsNothing);
      expect(find.text('Payment Pending'), findsOneWidget);
      await tester.tap(find.text('Pay Now'));
      expect(payTaps, 1);
    });

    testWidgets('verified paid booking shows Paid and receipt, never Pay Now', (
      tester,
    ) async {
      final booking = BookingEntity(
        id: '7ee40579-449b-46ce-b1f4-191604d79c71',
        status: 'completed',
        pickupAddress: 'Dhanmondi',
        dropoffAddress: 'Mirpur',
        finalFare: 25,
        currency: 'USD',
        meterPayment: _verifiedPaid(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RideHistoryCard(
              booking: booking,
              onTap: () {},
              onPayNow: () {},
            ),
          ),
        ),
      );
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('USD 4.80'), findsOneWidget);
      expect(find.text('Pay Now'), findsNothing);
      expect(find.text('USD 25.00'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeterPaymentCard(
              payment: _verifiedPaid(),
              onPayNow: () {},
              onViewReceipt: () {},
            ),
          ),
        ),
      );
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('View Receipt'), findsOneWidget);
      expect(find.text('Pay Now'), findsNothing);
    });

    test('verified paid JSON parses paymentRequired false', () {
      final parsed = RidePlanningParsers.meterPayment({
        'bookingId': '7ee40579-449b-46ce-b1f4-191604d79c71',
        'paymentStatus': 'paid',
        'paymentRequired': false,
        'finalFareCents': 480,
        'currency': 'USD',
        'receiptAvailable': true,
        'testMode': true,
        'productionCharge': false,
        'paymentMode': 'meter',
      });
      expect(parsed?.isPaid, isTrue);
      expect(parsed?.needsPayNow, isFalse);
      expect(parsed?.canShowPaidReceipt, isTrue);
      expect(parsed?.formattedFinalFare, 'USD 4.80');
    });

    testWidgets('paid history uses backend fare and hides quote', (
      tester,
    ) async {
      final booking = BookingEntity(
        id: 'paid-1',
        status: 'completed',
        pickupAddress: 'Dhanmondi',
        dropoffAddress: 'Mirpur',
        finalFare: 25,
        currency: 'USD',
        meterPayment: _pending().copyWith(
          bookingId: 'paid-1',
          paymentStatus: MeterPaymentStatus.paid,
          paymentRequired: false,
          receiptAvailable: true,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RideHistoryCard(booking: booking, onTap: () {}),
          ),
        ),
      );
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('USD 18.75'), findsOneWidget);
      expect(find.text('Pay Now'), findsNothing);
    });

    testWidgets('receipt shows backend breakdown only', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeterReceiptCard(
              receipt: _pending().copyWith(
                paymentStatus: MeterPaymentStatus.paid,
                paymentRequired: false,
                receiptAvailable: true,
                flagDropCents: 350,
                distanceChargeCents: 1200,
                waitingChargeCents: 325,
                totalCents: 1875,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Flag drop'), findsOneWidget);
      expect(find.text('Distance charge'), findsOneWidget);
      expect(find.text('Eligible stopped-time charge'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
    });
  });
}
