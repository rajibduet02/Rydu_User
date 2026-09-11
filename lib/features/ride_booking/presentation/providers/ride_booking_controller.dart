import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/maps/encoded_polyline_decoder.dart';
import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../../../core/payments/rydu_payments.dart';
import '../../../../core/payments/stripe_debug.dart';
import '../../../payment/presentation/providers/payment_method_provider.dart';
import '../../data/services/stripe_payment_gateway.dart';
import '../../data/utils/ride_planning_parsers.dart';
import '../../../../core/network/passenger_socket_service.dart';
import '../../domain/constants/ride_booking_type_ids.dart';
import '../../domain/entities/pickup_spot_entity.dart';
import '../../domain/entities/ride_planning_entities.dart';
import '../../domain/payments/payment_authorization_poller.dart';
import '../../domain/recording_consent_status.dart';
import '../models/ride_flow_extra.dart';
import '../models/ride_vehicle_option.dart';
import '../models/suggested_location.dart';
import 'ride_booking_dependencies.dart';

export '../../domain/constants/ride_booking_type_ids.dart';
export '../../domain/recording_consent_status.dart';

enum RidePlanningPhase {
  initial,
  permissionChecking,
  permissionDenied,
  locating,
  reverseGeocoding,
  pickupReady,
  searchingPlaces,
  autocompleteLoaded,
  resolvingSelectedPlace,
  destinationSelected,
  routeLoading,
  routeLoaded,
  quoteLoading,
  quoteLoaded,
  bookingCreating,
  paymentPending,
  bookingSearching,
  bookingOffered,
  driverAccepted,
  driverEnRoute,
  driverArrived,
  rideInProgress,
  completed,
  cancelled,
  expired,
  noDrivers,
  scheduled,
  error,
}

enum ActiveRideSocketStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  authFailed,
}

enum ActiveSearchField { none, pickup, destination }

enum PickupSource { none, currentLocation, manualSelection, restoredBooking }

class RideBookingState {
  const RideBookingState({
    this.selectedRideType = RideBookingTypeIds.ride,
    this.pickupLocation = '',
    this.destinationQuery = '',
    this.selectedDestination,
    this.suggestedLocations = const [],
    this.predictions = const [],
    this.activeSearchField = ActiveSearchField.none,
    this.pickupSource = PickupSource.none,
    this.isPickupResolved = false,
    this.rideOptions = const [],
    this.selectedVehicleId,
    this.selectedVehicle,
    this.estimatedFare,
    this.fareCurrency,
    this.paymentMethod = CardBookingPayment.label,
    this.paymentMethodCode = CardBookingPayment.code,
    this.paymentMethods = const [],
    this.selectedPickupSpotIndex = 0,
    this.pickupSpots = const [],
    this.pickupConfirmed = false,
    this.rentalHours,
    this.leaveOption,
    this.rentalVehicle,
    this.rentalPrice,
    this.isLoading = false,
    this.isSearchingPlaces = false,
    this.isResolvingPlace = false,
    this.isLoadingRoute = false,
    this.isLoadingQuote = false,
    this.isCreatingBooking = false,
    this.isCancelling = false,
    this.isLoadingPickupSpots = false,
    this.errorMessage,
    this.phase = RidePlanningPhase.initial,
    this.permissionStatus = AppLocationPermissionStatus.notDetermined,
    this.pickupPlace,
    this.dropoffPlace,
    this.routePreview,
    this.polylinePoints = const [],
    this.bookingId,
    this.bookingNumber,
    this.bookingStatus,
    this.idempotencyKey,
    this.cancelIdempotencyKey,
    this.assignedDriver,
    this.driverLocation,
    this.socketStatus = ActiveRideSocketStatus.idle,
    this.promotionBanner,
    this.rawPickupCoordinates,
    this.lastNavigatedPhaseKey,
    this.searchStartedAt,
    this.recordingConsentStatus = RecordingConsentStatus.unknown,
    this.recordingConsentInfo,
    this.recordingConsentError,
    this.lastRecordingConsentChoice,
    this.cardPaymentUiState = CardPaymentUiState.idle,
    this.bookingPayment,
    this.paymentClientSecret,
    this.stripeReady = false,
    this.isResolvingPayment = false,
  });

  final String selectedRideType;
  final String pickupLocation;
  final String destinationQuery;
  final SuggestedLocation? selectedDestination;
  final List<SuggestedLocation> suggestedLocations;
  final List<PlacePredictionEntity> predictions;
  final ActiveSearchField activeSearchField;
  final PickupSource pickupSource;
  final bool isPickupResolved;
  final List<RideVehicleOption> rideOptions;
  final String? selectedVehicleId;
  final RideVehicleOption? selectedVehicle;
  final String? estimatedFare;
  final String? fareCurrency;
  final String paymentMethod;
  final String paymentMethodCode;
  final List<PaymentMethodEntity> paymentMethods;
  final int selectedPickupSpotIndex;
  final List<PickupSpotEntity> pickupSpots;
  final bool pickupConfirmed;
  final int? rentalHours;
  final String? leaveOption;
  final String? rentalVehicle;
  final double? rentalPrice;
  final bool isLoading;
  final bool isSearchingPlaces;
  final bool isResolvingPlace;
  final bool isLoadingRoute;
  final bool isLoadingQuote;
  final bool isCreatingBooking;
  final bool isCancelling;
  final bool isLoadingPickupSpots;
  final String? errorMessage;
  final RidePlanningPhase phase;
  final AppLocationPermissionStatus permissionStatus;
  final PlaceEntity? pickupPlace;
  final PlaceEntity? dropoffPlace;
  final RoutePreviewEntity? routePreview;
  final List<({double lat, double lng})> polylinePoints;
  final String? bookingId;
  final String? bookingNumber;
  final String? bookingStatus;
  final String? idempotencyKey;
  final String? cancelIdempotencyKey;
  final AssignedDriverEntity? assignedDriver;
  final DriverLocationEntity? driverLocation;
  final ActiveRideSocketStatus socketStatus;
  final String? promotionBanner;
  final AppPosition? rawPickupCoordinates;
  final String? lastNavigatedPhaseKey;
  final DateTime? searchStartedAt;
  final RecordingConsentStatus recordingConsentStatus;
  final RecordingConsentInfo? recordingConsentInfo;
  final String? recordingConsentError;
  final bool? lastRecordingConsentChoice;
  final CardPaymentUiState cardPaymentUiState;
  final BookingPaymentEntity? bookingPayment;
  final String? paymentClientSecret;
  final bool stripeReady;
  final bool isResolvingPayment;

  bool get hasSelectedVehicle =>
      selectedVehicleId != null && selectedVehicle != null;

  bool get hasResolvedPickup {
    final place = pickupPlace;
    if (place == null || !place.hasCoordinates) return false;
    // GPS / restored / manual selections are valid with coordinates even when
    // placeId is empty. Tolerate a lost isPickupResolved flag after rebuilds
    // when the source still indicates a resolved pickup.
    if (isPickupResolved) return true;
    return pickupSource == PickupSource.currentLocation ||
        pickupSource == PickupSource.manualSelection ||
        pickupSource == PickupSource.restoredBooking;
  }

  bool get hasResolvedDestination =>
      dropoffPlace != null && dropoffPlace!.hasCoordinates;

  String unresolvedLocationsMessage() {
    final missingPickup = !hasResolvedPickup;
    final missingDestination = !hasResolvedDestination;
    final typedPickup =
        pickupLocation.trim().isNotEmpty && pickupSource == PickupSource.none;
    final typedDestination =
        destinationQuery.trim().isNotEmpty && dropoffPlace == null;

    if (missingPickup && missingDestination) {
      if (typedPickup || typedDestination) {
        return 'Select a location from the suggestions.';
      }
      return 'Please select pickup and destination locations.';
    }
    if (missingPickup) {
      if (typedPickup) {
        return 'Select a location from the suggestions.';
      }
      return 'Please select a pickup location.';
    }
    if (missingDestination) {
      if (typedDestination) {
        return 'Select a location from the suggestions.';
      }
      return 'Please select a destination from the suggestions.';
    }
    return '';
  }

  bool get canConfirmBooking =>
      hasSelectedVehicle &&
      hasResolvedPickup &&
      hasResolvedDestination &&
      !isCreatingBooking;

  bool get isSearchingForDriver =>
      phase == RidePlanningPhase.bookingSearching ||
      phase == RidePlanningPhase.bookingOffered;

  bool get isPaymentPending => phase == RidePlanningPhase.paymentPending;

  bool get showsCardPaymentPanel =>
      isPaymentPending ||
      cardPaymentUiState == CardPaymentUiState.preparing ||
      cardPaymentUiState == CardPaymentUiState.presentingSheet ||
      cardPaymentUiState == CardPaymentUiState.authorizing ||
      cardPaymentUiState == CardPaymentUiState.failed ||
      cardPaymentUiState == CardPaymentUiState.requiresAction;

  bool get canRetryCardPayment {
    if (!isPaymentPending &&
        cardPaymentUiState != CardPaymentUiState.failed &&
        cardPaymentUiState != CardPaymentUiState.requiresAction) {
      return false;
    }
    final secret = paymentClientSecret?.trim() ?? '';
    if (secret.isNotEmpty) return true;
    return bookingPayment?.needsPayment == true;
  }

  bool get isAssignedRidePhase =>
      phase == RidePlanningPhase.driverAccepted ||
      phase == RidePlanningPhase.driverEnRoute ||
      phase == RidePlanningPhase.driverArrived ||
      phase == RidePlanningPhase.rideInProgress;

  bool get isTerminalRidePhase =>
      phase == RidePlanningPhase.completed ||
      phase == RidePlanningPhase.cancelled ||
      phase == RidePlanningPhase.expired ||
      phase == RidePlanningPhase.noDrivers;

  /// Live booking the passenger can reopen from Home (not terminal).
  bool get hasActiveBooking =>
      bookingId != null &&
      bookingId!.isNotEmpty &&
      (isSearchingForDriver || isAssignedRidePhase || isPaymentPending);

  String get bookingPaymentLabel {
    if (paymentMethod.isNotEmpty && !isCashPaymentLabel(paymentMethod)) {
      return paymentMethod;
    }
    return CardBookingPayment.label;
  }

  String get destinationLabel {
    if (selectedDestination != null && selectedDestination!.name.isNotEmpty) {
      return selectedDestination!.name;
    }
    if (dropoffPlace != null) {
      if (dropoffPlace!.label.isNotEmpty) return dropoffPlace!.label;
      if (dropoffPlace!.address.isNotEmpty) return dropoffPlace!.address;
    }
    if (destinationQuery.trim().isNotEmpty) return destinationQuery.trim();
    return 'Destination';
  }

  String get serviceNameLabel {
    final name = selectedVehicle?.name.trim();
    if (name != null && name.isNotEmpty) return name;
    if (selectedRideType.isNotEmpty) return selectedRideType;
    return 'Ride';
  }

  String get cardPaymentStatusTitle {
    return switch (cardPaymentUiState) {
      CardPaymentUiState.preparing => 'Preparing payment',
      CardPaymentUiState.presentingSheet => 'Complete payment',
      CardPaymentUiState.authorizing => 'Authorizing payment',
      CardPaymentUiState.failed => 'Payment failed',
      CardPaymentUiState.requiresAction => 'Payment required',
      CardPaymentUiState.authorized => 'Payment authorized',
      CardPaymentUiState.idle => 'Payment required',
    };
  }

  String get cardPaymentStatusSubtitle {
    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      return errorMessage!;
    }
    return switch (cardPaymentUiState) {
      CardPaymentUiState.preparing => 'Setting up secure card payment…',
      CardPaymentUiState.presentingSheet => 'Enter your card in the secure Stripe sheet.',
      CardPaymentUiState.authorizing => 'Confirming authorization with Rydu…',
      CardPaymentUiState.failed => 'Your booking is saved. Retry payment or cancel the ride.',
      CardPaymentUiState.requiresAction =>
        'Complete payment to start finding a driver.',
      CardPaymentUiState.authorized => 'Finding a driver…',
      CardPaymentUiState.idle => 'Complete payment to start finding a driver.',
    };
  }

  String get activeRideStatusLabel {
    return switch (phase) {
      RidePlanningPhase.paymentPending =>
        cardPaymentUiState == CardPaymentUiState.failed
            ? 'Payment failed'
            : cardPaymentUiState == CardPaymentUiState.authorizing
            ? 'Authorizing payment'
            : cardPaymentUiState == CardPaymentUiState.preparing ||
                  cardPaymentUiState == CardPaymentUiState.presentingSheet
            ? 'Preparing payment'
            : 'Payment required',
      RidePlanningPhase.bookingSearching ||
      RidePlanningPhase.bookingOffered => 'Finding a driver…',
      RidePlanningPhase.driverAccepted ||
      RidePlanningPhase.driverEnRoute => 'Driver is on the way',
      RidePlanningPhase.driverArrived => 'Driver has arrived',
      RidePlanningPhase.rideInProgress => 'Ride in progress',
      RidePlanningPhase.expired ||
      RidePlanningPhase.noDrivers => 'No drivers are available right now.',
      _ => 'Active ride',
    };
  }

  bool get canCancelBooking =>
      bookingId != null &&
      !isCancelling &&
      (isSearchingForDriver ||
          isPaymentPending ||
          phase == RidePlanningPhase.driverAccepted);

  /// Consent prompt only after acceptance, while still required.
  bool get shouldShowRecordingConsentPrompt =>
      hasActiveBooking &&
      isAssignedRidePhase &&
      (recordingConsentStatus == RecordingConsentStatus.required ||
          recordingConsentStatus == RecordingConsentStatus.submitting ||
          recordingConsentStatus == RecordingConsentStatus.failed);

  String? get recordingConsentStatusLabel {
    return switch (recordingConsentStatus) {
      RecordingConsentStatus.granted => 'Ride safety recording allowed',
      RecordingConsentStatus.denied => 'Recording not allowed',
      _ => null,
    };
  }

  String get pickupSpotLabel {
    if (pickupSpots.isEmpty) {
      return pickupPlace?.label ?? pickupLocation;
    }
    final i = selectedPickupSpotIndex;
    if (i < 0 || i >= pickupSpots.length) return pickupSpots.first.label;
    return pickupSpots[i].label;
  }

  RideBookingState copyWith({
    String? selectedRideType,
    String? pickupLocation,
    String? destinationQuery,
    SuggestedLocation? selectedDestination,
    bool clearSelectedDestination = false,
    List<SuggestedLocation>? suggestedLocations,
    List<PlacePredictionEntity>? predictions,
    ActiveSearchField? activeSearchField,
    PickupSource? pickupSource,
    bool? isPickupResolved,
    List<RideVehicleOption>? rideOptions,
    String? selectedVehicleId,
    RideVehicleOption? selectedVehicle,
    bool clearSelectedVehicle = false,
    String? estimatedFare,
    bool clearEstimatedFare = false,
    String? fareCurrency,
    String? paymentMethod,
    String? paymentMethodCode,
    List<PaymentMethodEntity>? paymentMethods,
    int? selectedPickupSpotIndex,
    List<PickupSpotEntity>? pickupSpots,
    bool? pickupConfirmed,
    int? rentalHours,
    bool clearRentalContext = false,
    String? leaveOption,
    String? rentalVehicle,
    double? rentalPrice,
    bool? isLoading,
    bool? isSearchingPlaces,
    bool? isResolvingPlace,
    bool? isLoadingRoute,
    bool? isLoadingQuote,
    bool? isCreatingBooking,
    bool? isCancelling,
    bool? isLoadingPickupSpots,
    String? errorMessage,
    bool clearError = false,
    RidePlanningPhase? phase,
    AppLocationPermissionStatus? permissionStatus,
    PlaceEntity? pickupPlace,
    bool clearPickupPlace = false,
    PlaceEntity? dropoffPlace,
    bool clearDropoff = false,
    RoutePreviewEntity? routePreview,
    bool clearRoute = false,
    List<({double lat, double lng})>? polylinePoints,
    String? bookingId,
    bool clearBookingId = false,
    String? bookingNumber,
    String? bookingStatus,
    String? idempotencyKey,
    bool clearIdempotencyKey = false,
    String? cancelIdempotencyKey,
    bool clearCancelIdempotencyKey = false,
    AssignedDriverEntity? assignedDriver,
    bool clearAssignedDriver = false,
    DriverLocationEntity? driverLocation,
    bool clearDriverLocation = false,
    ActiveRideSocketStatus? socketStatus,
    String? promotionBanner,
    bool clearPromotionBanner = false,
    AppPosition? rawPickupCoordinates,
    String? lastNavigatedPhaseKey,
    DateTime? searchStartedAt,
    bool clearSearchStartedAt = false,
    RecordingConsentStatus? recordingConsentStatus,
    RecordingConsentInfo? recordingConsentInfo,
    bool clearRecordingConsentInfo = false,
    String? recordingConsentError,
    bool clearRecordingConsentError = false,
    bool? lastRecordingConsentChoice,
    bool clearLastRecordingConsentChoice = false,
    CardPaymentUiState? cardPaymentUiState,
    BookingPaymentEntity? bookingPayment,
    bool clearBookingPayment = false,
    String? paymentClientSecret,
    bool clearPaymentClientSecret = false,
    bool? stripeReady,
    bool? isResolvingPayment,
  }) {
    return RideBookingState(
      selectedRideType: selectedRideType ?? this.selectedRideType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationQuery: destinationQuery ?? this.destinationQuery,
      selectedDestination: clearSelectedDestination
          ? null
          : (selectedDestination ?? this.selectedDestination),
      suggestedLocations: suggestedLocations ?? this.suggestedLocations,
      predictions: predictions ?? this.predictions,
      activeSearchField: activeSearchField ?? this.activeSearchField,
      pickupSource: pickupSource ?? this.pickupSource,
      isPickupResolved: isPickupResolved ?? this.isPickupResolved,
      rideOptions: rideOptions ?? this.rideOptions,
      selectedVehicleId: clearSelectedVehicle
          ? null
          : (selectedVehicleId ?? this.selectedVehicleId),
      selectedVehicle: clearSelectedVehicle
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
      estimatedFare: clearEstimatedFare
          ? null
          : (estimatedFare ?? this.estimatedFare),
      fareCurrency: fareCurrency ?? this.fareCurrency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentMethodCode: paymentMethodCode ?? this.paymentMethodCode,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPickupSpotIndex:
          selectedPickupSpotIndex ?? this.selectedPickupSpotIndex,
      pickupSpots: pickupSpots ?? this.pickupSpots,
      pickupConfirmed: pickupConfirmed ?? this.pickupConfirmed,
      rentalHours: clearRentalContext
          ? null
          : (rentalHours ?? this.rentalHours),
      leaveOption: clearRentalContext
          ? null
          : (leaveOption ?? this.leaveOption),
      rentalVehicle: clearRentalContext
          ? null
          : (rentalVehicle ?? this.rentalVehicle),
      rentalPrice: clearRentalContext
          ? null
          : (rentalPrice ?? this.rentalPrice),
      isLoading: isLoading ?? this.isLoading,
      isSearchingPlaces: isSearchingPlaces ?? this.isSearchingPlaces,
      isResolvingPlace: isResolvingPlace ?? this.isResolvingPlace,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      isLoadingQuote: isLoadingQuote ?? this.isLoadingQuote,
      isCreatingBooking: isCreatingBooking ?? this.isCreatingBooking,
      isCancelling: isCancelling ?? this.isCancelling,
      isLoadingPickupSpots: isLoadingPickupSpots ?? this.isLoadingPickupSpots,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      phase: phase ?? this.phase,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      pickupPlace: clearPickupPlace ? null : (pickupPlace ?? this.pickupPlace),
      dropoffPlace: clearDropoff ? null : (dropoffPlace ?? this.dropoffPlace),
      routePreview: clearRoute ? null : (routePreview ?? this.routePreview),
      polylinePoints: polylinePoints ?? this.polylinePoints,
      bookingId: clearBookingId ? null : (bookingId ?? this.bookingId),
      bookingNumber: bookingNumber ?? this.bookingNumber,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      idempotencyKey: clearIdempotencyKey
          ? null
          : (idempotencyKey ?? this.idempotencyKey),
      cancelIdempotencyKey: clearCancelIdempotencyKey
          ? null
          : (cancelIdempotencyKey ?? this.cancelIdempotencyKey),
      assignedDriver: clearAssignedDriver
          ? null
          : (assignedDriver ?? this.assignedDriver),
      driverLocation: clearDriverLocation
          ? null
          : (driverLocation ?? this.driverLocation),
      socketStatus: socketStatus ?? this.socketStatus,
      promotionBanner: clearPromotionBanner
          ? null
          : (promotionBanner ?? this.promotionBanner),
      rawPickupCoordinates: rawPickupCoordinates ?? this.rawPickupCoordinates,
      lastNavigatedPhaseKey:
          lastNavigatedPhaseKey ?? this.lastNavigatedPhaseKey,
      searchStartedAt: clearSearchStartedAt
          ? null
          : (searchStartedAt ?? this.searchStartedAt),
      recordingConsentStatus:
          recordingConsentStatus ?? this.recordingConsentStatus,
      recordingConsentInfo: clearRecordingConsentInfo
          ? null
          : (recordingConsentInfo ?? this.recordingConsentInfo),
      recordingConsentError: clearRecordingConsentError
          ? null
          : (recordingConsentError ?? this.recordingConsentError),
      lastRecordingConsentChoice: clearLastRecordingConsentChoice
          ? null
          : (lastRecordingConsentChoice ?? this.lastRecordingConsentChoice),
      cardPaymentUiState: cardPaymentUiState ?? this.cardPaymentUiState,
      bookingPayment: clearBookingPayment
          ? null
          : (bookingPayment ?? this.bookingPayment),
      paymentClientSecret: clearPaymentClientSecret
          ? null
          : (paymentClientSecret ?? this.paymentClientSecret),
      stripeReady: stripeReady ?? this.stripeReady,
      isResolvingPayment: isResolvingPayment ?? this.isResolvingPayment,
    );
  }
}

RidePlanningPhase ridePhaseFromBookingStatus(String status) {
  return switch (status.toLowerCase()) {
    'quoted' => RidePlanningPhase.paymentPending,
    'searching' ||
    'requested' ||
    'pending' ||
    'created' => RidePlanningPhase.bookingSearching,
    'offered' => RidePlanningPhase.bookingOffered,
    'accepted' => RidePlanningPhase.driverAccepted,
    'en_route' || 'driver_en_route' => RidePlanningPhase.driverEnRoute,
    'arrived' || 'driver_arrived' => RidePlanningPhase.driverArrived,
    'in_progress' || 'ongoing' || 'started' => RidePlanningPhase.rideInProgress,
    'completed' => RidePlanningPhase.completed,
    'cancelled' || 'canceled' => RidePlanningPhase.cancelled,
    'expired' => RidePlanningPhase.expired,
    'no_drivers' || 'no_driver' => RidePlanningPhase.noDrivers,
    'scheduled' => RidePlanningPhase.scheduled,
    _ => RidePlanningPhase.bookingSearching,
  };
}

class RideBookingController extends Notifier<RideBookingState> {
  static const _uuid = Uuid();
  Timer? _autocompleteDebounce;
  CancelToken? _autocompleteCancelToken;
  int _autocompleteRequestId = 0;
  String? _placesSessionToken;
  StreamSubscription<Map<String, dynamic>>? _bookingSub;
  StreamSubscription<DriverLocationEntity>? _driverSub;
  StreamSubscription<Map<String, dynamic>>? _recordingSub;
  StreamSubscription<PassengerSocketConnectionStatus>? _socketStatusSub;
  bool _locationBootstrapStarted = false;
  DateTime? _lastDriverLocationAt;
  PlaceEntity? _previousResolvedPickup;
  PickupSource _previousPickupSource = PickupSource.none;
  int _routeQuoteActionId = 0;
  bool _navigatingToSelection = false;
  bool suppressPickupTextInvalidation = false;
  ActiveRideSocketStatus? _previousSocketStatus;
  bool _refreshingRecordingConsent = false;
  bool _authorizingPayment = false;

  @override
  RideBookingState build() {
    ref.onDispose(() {
      _autocompleteDebounce?.cancel();
      _autocompleteCancelToken?.cancel();
      unawaited(_cancelSocketSubscriptions());
    });
    return const RideBookingState();
  }

  /// Test-only state seed (avoids platform Secure Storage during unit tests).
  @visibleForTesting
  void debugSeedState(RideBookingState next) {
    state = next;
  }

  /// Test-only: country query sent to Places autocomplete.
  @visibleForTesting
  String? debugResolvedAutocompleteCountry() => _resolvedAutocompleteCountry();

  /// Test-only: run autocomplete without the 400ms debounce.
  @visibleForTesting
  Future<void> debugRunAutocomplete(String input, ActiveSearchField field) {
    return _runAutocomplete(input, field);
  }

  Future<void> _cancelSocketSubscriptions() async {
    await _bookingSub?.cancel();
    await _driverSub?.cancel();
    await _recordingSub?.cancel();
    await _socketStatusSub?.cancel();
    _bookingSub = null;
    _driverSub = null;
    _recordingSub = null;
    _socketStatusSub = null;
  }

  Future<void> loadInitialData() async {
    try {
      state = state.copyWith(
        pickupLocation: state.pickupPlace?.label ?? state.pickupLocation,
        suggestedLocations: const [],
        clearError: true,
      );
      if (state.hasResolvedPickup) {
        if (kDebugMode) {
          debugPrint(
            'PickupBootstrap: skipped — already resolved '
            'source=${state.pickupSource.name}',
          );
        }
        return;
      }
      await bootstrapCurrentLocation(userInitiated: false);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Could not load locations.');
    }
  }

  Future<void> bootstrapCurrentLocation({bool userInitiated = false}) async {
    if (kDebugMode) {
      debugPrint(
        'PickupBootstrap: started userInitiated=$userInitiated '
        'alreadyStarted=$_locationBootstrapStarted',
      );
    }

    if (_locationBootstrapStarted && !userInitiated) {
      _repairPickupResolvedFlag();
      if (kDebugMode) {
        debugPrint(
          'PickupBootstrap: early-return repaired='
          '${state.hasResolvedPickup}',
        );
      }
      return;
    }
    _locationBootstrapStarted = true;

    state = state.copyWith(
      phase: RidePlanningPhase.permissionChecking,
      activeSearchField: userInitiated
          ? ActiveSearchField.pickup
          : state.activeSearchField,
      predictions: userInitiated ? const [] : state.predictions,
      isSearchingPlaces: userInitiated ? false : state.isSearchingPlaces,
      clearError: true,
    );

    final location = ref.read(locationServiceProvider);
    final serviceEnabled = await location.isServiceEnabled();
    if (kDebugMode) {
      debugPrint('PickupBootstrap: serviceEnabled=$serviceEnabled');
    }
    if (!serviceEnabled) {
      state = state.copyWith(
        phase: RidePlanningPhase.permissionDenied,
        permissionStatus: AppLocationPermissionStatus.serviceDisabled,
        errorMessage:
            'Location services are disabled. Enable GPS or search pickup manually.',
      );
      return;
    }

    var status = await location.checkPermission();
    if (status == AppLocationPermissionStatus.denied ||
        status == AppLocationPermissionStatus.notDetermined) {
      status = await location.requestPermission();
    }
    state = state.copyWith(permissionStatus: status);
    if (kDebugMode) {
      debugPrint('PickupBootstrap: permission=${status.name}');
    }

    if (status == AppLocationPermissionStatus.deniedForever ||
        status == AppLocationPermissionStatus.denied ||
        status == AppLocationPermissionStatus.serviceDisabled) {
      state = state.copyWith(
        phase: RidePlanningPhase.permissionDenied,
        errorMessage: status == AppLocationPermissionStatus.deniedForever
            ? 'Location permission is blocked. Open settings or search pickup manually.'
            : status == AppLocationPermissionStatus.serviceDisabled
            ? 'Location services are disabled. Enable GPS or search pickup manually.'
            : 'Location permission is required for automatic pickup. You can search pickup manually.',
      );
      return;
    }

    state = state.copyWith(phase: RidePlanningPhase.locating, isLoading: true);
    final position = await location.getCurrentPosition();
    if (position == null) {
      state = state.copyWith(
        isLoading: false,
        phase: RidePlanningPhase.error,
        errorMessage:
            'Could not get current location. Retry or search pickup manually.',
      );
      if (kDebugMode) {
        debugPrint('PickupBootstrap: gps failed');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('PickupBootstrap: gps latPresent=true lngPresent=true');
    }

    state = state.copyWith(
      rawPickupCoordinates: position,
      phase: RidePlanningPhase.reverseGeocoding,
    );

    PlaceEntity resolved;
    try {
      final place = await ref
          .read(rideBookingRepositoryProvider)
          .reverseGeocode(lat: position.latitude, lng: position.longitude);
      if (kDebugMode) {
        debugPrint(
          'PickupBootstrap: reverseGeocode status='
          '${place == null ? 'empty' : 'ok'}',
        );
      }
      resolved =
          place ??
          PlaceEntity(
            placeId: '',
            label: 'Current location',
            address:
                '${position.latitude.toStringAsFixed(5)}, '
                '${position.longitude.toStringAsFixed(5)}',
            latitude: position.latitude,
            longitude: position.longitude,
          );
      // GPS pickup is valid even with empty placeId.
      if (!resolved.hasCoordinates) {
        resolved = PlaceEntity(
          placeId: resolved.placeId,
          label: resolved.label.isNotEmpty
              ? resolved.label
              : 'Current location',
          address: resolved.address.isNotEmpty
              ? resolved.address
              : '${position.latitude.toStringAsFixed(5)}, '
                    '${position.longitude.toStringAsFixed(5)}',
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
      _applyResolvedCurrentPickup(resolved, clearError: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PickupBootstrap: reverseGeocode status=error');
      }
      resolved = PlaceEntity(
        placeId: '',
        label: 'Current location',
        address:
            '${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)}',
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _applyResolvedCurrentPickup(
        resolved,
        errorMessage: e is PassengerApiException
            ? '${e.message} Using current coordinates — you can search pickup manually.'
            : 'Could not reverse-geocode. Using current coordinates.',
      );
    }

    if (kDebugMode) {
      debugPrint(
        'PickupBootstrap: pickupResolved=${state.hasResolvedPickup} '
        'placeIdEmpty=${resolved.placeId.isEmpty}',
      );
    }
    unawaited(_loadBackendSuggestions());
  }

  void _applyResolvedCurrentPickup(
    PlaceEntity resolved, {
    String? errorMessage,
    bool clearError = false,
  }) {
    state = state.copyWith(
      isLoading: false,
      pickupPlace: resolved,
      pickupLocation: resolved.label.isNotEmpty
          ? resolved.label
          : (resolved.address.isNotEmpty
                ? resolved.address
                : 'Current location'),
      pickupSource: PickupSource.currentLocation,
      isPickupResolved: true,
      phase: RidePlanningPhase.pickupReady,
      errorMessage: errorMessage,
      clearError: clearError,
    );
    _stashResolvedPickup(resolved, PickupSource.currentLocation);
  }

  void _repairPickupResolvedFlag() {
    final place = state.pickupPlace;
    if (place != null &&
        place.hasCoordinates &&
        !state.isPickupResolved &&
        state.pickupSource != PickupSource.none) {
      state = state.copyWith(isPickupResolved: true);
      return;
    }
    if (place != null && place.hasCoordinates && !state.isPickupResolved) {
      // Coords exist (e.g. after state rebuild) — treat as current/restored.
      state = state.copyWith(
        isPickupResolved: true,
        pickupSource: state.pickupSource == PickupSource.none
            ? PickupSource.currentLocation
            : state.pickupSource,
        pickupLocation: state.pickupLocation.isNotEmpty
            ? state.pickupLocation
            : place.label,
      );
      _stashResolvedPickup(place, state.pickupSource);
    }
  }

  void _stashResolvedPickup(PlaceEntity place, PickupSource source) {
    _previousResolvedPickup = place;
    _previousPickupSource = source;
  }

  /// Places autocomplete `country` from location truth only (never phone/locale).
  ///
  /// 1. Resolved pickup `countryCode`
  /// 2. GPS reverse-geocode / previously selected pickup (stash), used when
  ///    the user is retyping pickup and `pickupPlace` was cleared
  /// 3. Omit if missing or not a 2-letter ISO code
  String? _resolvedAutocompleteCountry() {
    final fromPickup = RidePlanningParsers.normalizedCountryCode(
      state.pickupPlace?.countryCode,
    );
    if (fromPickup != null) return fromPickup;
    return RidePlanningParsers.normalizedCountryCode(
      _previousResolvedPickup?.countryCode,
    );
  }

  Future<void> useCurrentLocation() async {
    if (kDebugMode) debugPrint('PickupCurrentLocation: selected');
    // Preserve destination; only reset pickup search UI.
    state = state.copyWith(
      activeSearchField: ActiveSearchField.pickup,
      predictions: const [],
      isSearchingPlaces: false,
      clearError: true,
    );
    _locationBootstrapStarted = false;
    await bootstrapCurrentLocation(userInitiated: true);
    if (state.hasResolvedPickup && state.hasResolvedDestination) {
      await _previewRouteAndOpenSelection();
    }
  }

  void cancelPickupEditing() {
    final previous = _previousResolvedPickup;
    if (previous == null || !previous.hasCoordinates) return;
    state = state.copyWith(
      pickupPlace: previous,
      pickupLocation: previous.label.isNotEmpty
          ? previous.label
          : previous.address,
      pickupSource: _previousPickupSource,
      isPickupResolved: true,
      predictions: const [],
      isSearchingPlaces: false,
      activeSearchField: ActiveSearchField.none,
      clearError: true,
      phase: RidePlanningPhase.pickupReady,
    );
  }

  Future<void> openAppSettingsForLocation() async {
    await ref.read(locationServiceProvider).openAppSettings();
  }

  Future<void> _loadBackendSuggestions() async {
    final pickup = state.pickupPlace;
    try {
      final predictions = await ref
          .read(rideBookingRepositoryProvider)
          .placeSuggestions(lat: pickup?.latitude, lng: pickup?.longitude);
      if (predictions.isEmpty) return;
      final mapped = predictions
          .map(
            (p) => RideDestinationEntity(
              id: p.placeId,
              name: p.primaryText,
              address: p.secondaryText,
              distance: '',
              latitude: p.latitude,
              longitude: p.longitude,
              placeId: p.placeId,
            ),
          )
          .toList();
      state = state.copyWith(suggestedLocations: mapped);
    } catch (_) {
      // Keep local fallback suggestions.
    }
  }

  void initializeSelectedType(
    String type, {
    int? rentalHours,
    String? leaveOption,
    String? rentalVehicle,
    double? rentalPrice,
    String? paymentMethod,
  }) {
    final existingPickup = state.pickupPlace;
    final alreadyResolved =
        existingPickup != null &&
        existingPickup.hasCoordinates &&
        (state.isPickupResolved ||
            state.pickupSource == PickupSource.currentLocation ||
            state.pickupSource == PickupSource.manualSelection ||
            state.pickupSource == PickupSource.restoredBooking);

    final source = alreadyResolved
        ? (state.pickupSource == PickupSource.none
              ? PickupSource.currentLocation
              : state.pickupSource)
        : PickupSource.none;

    state = RideBookingState(
      selectedRideType: type.isEmpty ? RideBookingTypeIds.ride : type,
      pickupLocation: alreadyResolved
          ? (existingPickup.label.isNotEmpty
                ? existingPickup.label
                : existingPickup.address)
          : '',
      pickupPlace: alreadyResolved ? existingPickup : null,
      pickupSource: source,
      isPickupResolved: alreadyResolved,
      rawPickupCoordinates: state.rawPickupCoordinates,
      destinationQuery: '',
      selectedDestination: null,
      suggestedLocations: const [],
      rentalHours: rentalHours,
      leaveOption: leaveOption,
      rentalVehicle: rentalVehicle,
      rentalPrice: rentalPrice,
      paymentMethod: paymentMethod ?? state.bookingPaymentLabel,
      paymentMethodCode: CardBookingPayment.code,
      isLoading: false,
      errorMessage: null,
      phase: alreadyResolved
          ? RidePlanningPhase.pickupReady
          : RidePlanningPhase.initial,
    );

    if (alreadyResolved) {
      _stashResolvedPickup(existingPickup, source);
      unawaited(_loadBackendSuggestions());
    } else {
      _locationBootstrapStarted = false;
      unawaited(loadInitialData());
    }
  }

  Future<void> initializeFromExtra(Map<String, dynamic> extra) async {
    final type = RideFlowExtra.stringFrom(
      extra['selectedType'],
      RideBookingTypeIds.ride,
    );
    final pickup = RideFlowExtra.stringFrom(
      extra['pickupLocation'],
      state.pickupLocation,
    );
    final destination = RideFlowExtra.destinationFrom(extra['destination']);
    final vehicle = rideVehicleOptionFromExtra(extra['selectedVehicle']);
    final vehicleId = vehicle?.id ?? extra['selectedVehicleId'] as String?;
    final fare = extra['estimatedFare'] as String?;
    final payment = RideFlowExtra.stringFrom(
      extra['paymentMethod'],
      CardBookingPayment.label,
    );
    final paymentLabel = isCashPaymentLabel(payment)
        ? CardBookingPayment.label
        : payment;
    ref
        .read(paymentMethodControllerProvider.notifier)
        .selectPaymentMethod(paymentLabel);
    final spotIndex = extra['selectedPickupSpotIndex'] as int? ?? 0;

    state = state.copyWith(
      selectedRideType: type,
      pickupLocation: pickup,
      destinationQuery: destination?.name ?? state.destinationQuery,
      selectedDestination: destination,
      selectedVehicleId: vehicleId ?? vehicle?.id,
      selectedVehicle: vehicle,
      estimatedFare: fare ?? vehicle?.price,
      paymentMethod: paymentLabel,
      paymentMethodCode: CardBookingPayment.code,
      selectedPickupSpotIndex: spotIndex,
      clearError: true,
    );

    if (state.routePreview == null &&
        state.pickupPlace != null &&
        state.dropoffPlace != null) {
      await loadQuotesForCurrentTrip();
    } else if (state.routePreview != null && state.rideOptions.isEmpty) {
      await loadQuotesForCurrentTrip();
    }
  }

  void setActiveSearchField(ActiveSearchField field) {
    if (state.activeSearchField == field) return;
    // Switching fields clears the previous field's suggestion list only.
    state = state.copyWith(
      activeSearchField: field,
      predictions: const [],
      isSearchingPlaces: false,
      clearError: true,
    );
  }

  void updatePickupLocation(String value) {
    if (suppressPickupTextInvalidation) {
      // Programmatic TextEditingController updates must not clear coordinates.
      return;
    }

    final trimmed = value.trim();
    final resolvedLabel = (state.pickupPlace?.label.trim().isNotEmpty == true
        ? state.pickupPlace!.label.trim()
        : state.pickupPlace?.address.trim() ?? '');
    final diverged =
        state.hasResolvedPickup &&
        resolvedLabel.isNotEmpty &&
        trimmed != resolvedLabel;

    state = state.copyWith(
      pickupLocation: value,
      activeSearchField: ActiveSearchField.pickup,
      clearPickupPlace: diverged,
      isPickupResolved: diverged ? false : state.isPickupResolved,
      pickupSource: diverged ? PickupSource.none : state.pickupSource,
      clearError: true,
    );
    _scheduleAutocomplete(value, ActiveSearchField.pickup);
  }

  void updateDestinationQuery(String value) {
    state = state.copyWith(
      destinationQuery: value,
      activeSearchField: ActiveSearchField.destination,
      clearSelectedDestination: true,
      clearDropoff: true,
      clearRoute: true,
      clearError: true,
    );
    _scheduleAutocomplete(value, ActiveSearchField.destination);
  }

  void _scheduleAutocomplete(String value, ActiveSearchField field) {
    _autocompleteDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      _autocompleteCancelToken?.cancel('stale');
      state = state.copyWith(
        predictions: const [],
        isSearchingPlaces: false,
        activeSearchField: field,
        phase: state.pickupPlace != null
            ? RidePlanningPhase.pickupReady
            : RidePlanningPhase.initial,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      isSearchingPlaces: true,
      activeSearchField: field,
      phase: RidePlanningPhase.searchingPlaces,
      clearError: true,
    );
    _autocompleteDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_runAutocomplete(trimmed, field));
    });
  }

  Future<void> _runAutocomplete(String input, ActiveSearchField field) async {
    final requestId = ++_autocompleteRequestId;
    _autocompleteCancelToken?.cancel('stale');
    final cancelToken = CancelToken();
    _autocompleteCancelToken = cancelToken;
    _placesSessionToken ??= _uuid.v4();
    final country = _resolvedAutocompleteCountry();

    if (kDebugMode) {
      debugPrint(
        'PassengerAutocomplete: start input="$input" field=${field.name} '
        'requestId=$requestId country=${country ?? '<none>'}',
      );
    }

    try {
      final bias = state.pickupPlace;
      final results = await ref
          .read(rideBookingRepositoryProvider)
          .autocomplete(
            input: input,
            lat: bias?.latitude,
            lng: bias?.longitude,
            country: country,
            sessionToken: _placesSessionToken,
            cancelToken: cancelToken,
          );
      if (requestId != _autocompleteRequestId) {
        if (kDebugMode) {
          debugPrint(
            'PassengerAutocomplete: ignored stale requestId=$requestId',
          );
        }
        return;
      }
      if (kDebugMode) {
        debugPrint(
          'PassengerAutocomplete: completed count=${results.length} '
          'requestId=$requestId',
        );
      }
      state = state.copyWith(
        predictions: results,
        isSearchingPlaces: false,
        activeSearchField: field,
        phase: RidePlanningPhase.autocompleteLoaded,
        clearError: true,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return;
      if (requestId != _autocompleteRequestId) return;
      final mapped = PassengerApiErrorMapper.fromDio(e);
      if (kDebugMode) {
        debugPrint(
          'PassengerAutocomplete: error status=${e.response?.statusCode} '
          'code=${mapped.code} message=${mapped.message}',
        );
      }
      state = state.copyWith(
        isSearchingPlaces: false,
        predictions: const [],
        phase: RidePlanningPhase.error,
        errorMessage: mapped.message.isNotEmpty
            ? mapped.message
            : 'Couldn’t load locations. Please try again.',
      );
    } catch (e) {
      if (requestId != _autocompleteRequestId) return;
      if (kDebugMode) {
        debugPrint('PassengerAutocomplete: unexpected error $e');
      }
      state = state.copyWith(
        isSearchingPlaces: false,
        predictions: const [],
        phase: RidePlanningPhase.error,
        errorMessage: e is PassengerApiException
            ? e.message
            : 'Couldn’t load locations. Please try again.',
      );
    }
  }

  Future<void> selectDestination(String locationId) async {
    final prediction = state.predictions
        .where((p) => p.placeId == locationId)
        .firstOrNull;
    if (prediction != null) {
      await selectPrediction(prediction);
      return;
    }

    final found = await ref
        .read(selectDestinationUsecaseProvider)
        .call(locationId);
    if (found == null) return;

    if (found.placeId != null && found.placeId!.isNotEmpty) {
      await selectPrediction(
        PlacePredictionEntity(
          placeId: found.placeId!,
          primaryText: found.name,
          secondaryText: found.address,
          latitude: found.latitude,
          longitude: found.longitude,
        ),
      );
      return;
    }

    // Local mock suggestion without placeId — cannot build a real route.
    state = state.copyWith(
      selectedDestination: found,
      destinationQuery: found.name,
      errorMessage:
          'This saved suggestion has no placeId. Search and select a place.',
    );
  }

  Future<void> selectPrediction(PlacePredictionEntity prediction) async {
    final targetField = state.activeSearchField == ActiveSearchField.pickup
        ? ActiveSearchField.pickup
        : ActiveSearchField.destination;

    state = state.copyWith(
      isResolvingPlace: true,
      phase: RidePlanningPhase.resolvingSelectedPlace,
      activeSearchField: targetField,
      destinationQuery: targetField == ActiveSearchField.destination
          ? prediction.primaryText
          : state.destinationQuery,
      pickupLocation: targetField == ActiveSearchField.pickup
          ? prediction.primaryText
          : state.pickupLocation,
      clearError: true,
    );
    try {
      final details = await ref
          .read(rideBookingRepositoryProvider)
          .placeDetails(
            placeId: prediction.placeId,
            sessionToken: _placesSessionToken,
          );
      _placesSessionToken = null;
      if (details == null || !details.hasCoordinates) {
        state = state.copyWith(
          isResolvingPlace: false,
          phase: RidePlanningPhase.error,
          errorMessage:
              'Could not resolve place coordinates. Please try again.',
        );
        return;
      }

      if (targetField == ActiveSearchField.pickup) {
        state = state.copyWith(
          isResolvingPlace: false,
          pickupPlace: details,
          pickupLocation: details.label,
          pickupSource: PickupSource.manualSelection,
          isPickupResolved: true,
          predictions: const [],
          activeSearchField: ActiveSearchField.none,
          phase: RidePlanningPhase.pickupReady,
        );
        _stashResolvedPickup(details, PickupSource.manualSelection);
        if (kDebugMode) {
          debugPrint(
            'PickupManualSelection: placeDetailsResolved=true '
            'label=${details.label}',
          );
        }
        if (state.hasResolvedDestination) {
          await _previewRouteAndOpenSelection();
        }
        return;
      }

      final destination = RideDestinationEntity(
        id: details.placeId,
        name: details.label,
        address: details.address,
        distance: '',
        latitude: details.latitude,
        longitude: details.longitude,
        placeId: details.placeId,
      );

      state = state.copyWith(
        isResolvingPlace: false,
        dropoffPlace: details,
        selectedDestination: destination,
        destinationQuery: details.label,
        predictions: const [],
        activeSearchField: ActiveSearchField.none,
        phase: RidePlanningPhase.destinationSelected,
      );

      await _previewRouteAndOpenSelection();
    } catch (e) {
      state = state.copyWith(
        isResolvingPlace: false,
        phase: RidePlanningPhase.error,
        errorMessage: e is PassengerApiException
            ? e.message
            : 'Could not load place details. Please try again.',
      );
    }
  }

  Future<void> _previewRouteAndOpenSelection() async {
    if (!state.hasResolvedPickup || !state.hasResolvedDestination) {
      state = state.copyWith(errorMessage: state.unresolvedLocationsMessage());
      if (kDebugMode) {
        debugPrint(
          'RoutePreview: blocked pickupResolved=${state.hasResolvedPickup} '
          'destinationResolved=${state.hasResolvedDestination}',
        );
      }
      return;
    }

    final pickup = state.pickupPlace!;
    final dropoff = state.dropoffPlace!;
    final actionId = ++_routeQuoteActionId;

    state = state.copyWith(
      isLoadingRoute: true,
      isLoadingQuote: true,
      phase: RidePlanningPhase.routeLoading,
      clearError: true,
      clearPromotionBanner: true,
    );

    try {
      if (kDebugMode) {
        debugPrint('RoutePreview: start actionId=$actionId');
      }
      final route = await ref
          .read(rideBookingRepositoryProvider)
          .previewRoute(
            pickup: _waypointFromPlace(pickup),
            dropoff: _waypointFromPlace(dropoff),
          );
      if (actionId != _routeQuoteActionId) return;

      final points = EncodedPolylineDecoder.decode(route.encodedPolyline);
      final routeOk =
          route.encodedPolyline.isNotEmpty &&
          route.distanceMeters > 0 &&
          route.durationSeconds > 0 &&
          (route.routeBounds.isValid || points.length >= 2);

      if (!routeOk) {
        state = state.copyWith(
          isLoadingRoute: false,
          isLoadingQuote: false,
          phase: RidePlanningPhase.error,
          errorMessage: 'Could not build a valid route. Please try again.',
        );
        if (kDebugMode) {
          debugPrint(
            'RoutePreview: invalid polylineLen=${points.length} '
            'boundsValid=${route.routeBounds.isValid}',
          );
        }
        return;
      }

      state = state.copyWith(
        isLoadingRoute: false,
        routePreview: route,
        polylinePoints: points,
        phase: RidePlanningPhase.quoteLoading,
      );

      if (kDebugMode) {
        debugPrint(
          'RoutePreview: ok polylineLen=${points.length} '
          'boundsValid=${route.routeBounds.isValid}',
        );
      }

      final quote = await ref
          .read(rideBookingRepositoryProvider)
          .quoteBooking(
            pickup: _waypointFromPlace(pickup),
            dropoff: _waypointFromPlace(dropoff),
          );
      if (actionId != _routeQuoteActionId) return;

      final options = quote.quotes
          .map((q) => rideOptionFromQuote(q))
          .where((o) => o.id.isNotEmpty && o.price.isNotEmpty)
          .toList(growable: false);

      if (options.isEmpty) {
        state = state.copyWith(
          isLoadingQuote: false,
          rideOptions: const [],
          clearSelectedVehicle: true,
          clearEstimatedFare: true,
          clearPromotionBanner: true,
          phase: RidePlanningPhase.error,
          errorMessage: 'No ride quotes available for this route.',
        );
        return;
      }

      final methods = await ref
          .read(rideBookingRepositoryProvider)
          .paymentMethods();
      if (actionId != _routeQuoteActionId) return;
      unawaited(_loadPaymentConfigQuietly());
      final payment = _cardPaymentSelection(methods);

      final promotionTitle = quote.quotes
          .map((q) => q.promotion?.displayTitle)
          .whereType<String>()
          .where((p) => p.trim().isNotEmpty)
          .where((p) => !(p.startsWith('{') && p.contains(':')))
          .firstOrNull;

      final quotePoints = points.isNotEmpty
          ? points
          : EncodedPolylineDecoder.decode(quote.route.encodedPolyline);

      state = state.copyWith(
        isLoadingQuote: false,
        rideOptions: options,
        routePreview: quote.route.encodedPolyline.isNotEmpty
            ? quote.route
            : route,
        polylinePoints: quotePoints,
        paymentMethods: payment.methods,
        paymentMethod: payment.label,
        paymentMethodCode: payment.code,
        fareCurrency: quote.quotes.first.currency,
        promotionBanner: promotionTitle,
        clearPromotionBanner: promotionTitle == null,
        selectedVehicleId: options.first.id,
        selectedVehicle: options.first,
        estimatedFare: options.first.price,
        phase: RidePlanningPhase.quoteLoaded,
      );

      if (kDebugMode) {
        debugPrint(
          'Quote: count=${options.length} promotionTitle=$promotionTitle',
        );
      }

      _navigateToRideSelectionOnce();
    } catch (e) {
      if (actionId != _routeQuoteActionId) return;
      state = state.copyWith(
        isLoadingRoute: false,
        isLoadingQuote: false,
        phase: RidePlanningPhase.error,
        errorMessage: e is PassengerApiException
            ? e.message
            : 'Could not load route or quotes. Please try again.',
      );
      if (kDebugMode) {
        debugPrint('RouteQuote: failed $e');
      }
    }
  }

  void _navigateToRideSelectionOnce() {
    if (_navigatingToSelection) return;
    if (!state.hasResolvedPickup || !state.hasResolvedDestination) return;
    if (state.rideOptions.isEmpty) return;
    _navigatingToSelection = true;
    if (kDebugMode) {
      debugPrint('Navigation: Ride Selection');
    }
    continueToRideSelection();
    // Allow a later trip after user returns.
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      _navigatingToSelection = false;
    });
  }

  Future<void> loadQuotesForCurrentTrip() async {
    final pickup = state.pickupPlace;
    final dropoff = state.dropoffPlace;
    if (pickup == null || dropoff == null) return;

    state = state.copyWith(
      isLoadingQuote: true,
      phase: RidePlanningPhase.quoteLoading,
      clearError: true,
    );
    try {
      final quote = await ref
          .read(rideBookingRepositoryProvider)
          .quoteBooking(
            pickup: _waypointFromPlace(pickup),
            dropoff: _waypointFromPlace(dropoff),
          );
      final options = quote.quotes
          .map((q) => rideOptionFromQuote(q))
          .toList(growable: false);
      final methods = await ref
          .read(rideBookingRepositoryProvider)
          .paymentMethods();
      unawaited(_loadPaymentConfigQuietly());
      final payment = _cardPaymentSelection(methods);

      final promotion = quote.quotes
          .map((q) => q.promotion?.displayTitle)
          .whereType<String>()
          .where((p) => p.trim().isNotEmpty)
          .where((p) => !(p.startsWith('{') && p.contains(':')))
          .firstOrNull;

      final points = state.polylinePoints.isNotEmpty
          ? state.polylinePoints
          : EncodedPolylineDecoder.decode(quote.route.encodedPolyline);

      state = state.copyWith(
        isLoadingQuote: false,
        rideOptions: options,
        routePreview: quote.route,
        polylinePoints: points,
        paymentMethods: payment.methods,
        paymentMethod: payment.label,
        paymentMethodCode: payment.code,
        fareCurrency: options.isNotEmpty
            ? (quote.quotes.first.currency)
            : state.fareCurrency,
        promotionBanner: promotion,
        clearPromotionBanner: promotion == null,
        selectedVehicleId: options.isNotEmpty ? options.first.id : null,
        selectedVehicle: options.isNotEmpty ? options.first : null,
        estimatedFare: options.isNotEmpty ? options.first.price : null,
        clearEstimatedFare: options.isEmpty,
        clearSelectedVehicle: options.isEmpty,
        phase: RidePlanningPhase.quoteLoaded,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingQuote: false,
        rideOptions: const [],
        clearSelectedVehicle: true,
        clearEstimatedFare: true,
        phase: RidePlanningPhase.error,
        errorMessage: e is PassengerApiException
            ? e.message
            : 'Could not load ride quotes.',
      );
    }
  }

  Future<void> selectVehicle(String vehicleId) async {
    RideOptionEntity? found;
    for (final option in state.rideOptions) {
      if (option.id == vehicleId) {
        found = option;
        break;
      }
    }
    if (found == null) return;
    state = state.copyWith(
      selectedVehicleId: vehicleId,
      selectedVehicle: found,
      estimatedFare: found.price,
      clearError: true,
      clearIdempotencyKey: true,
    );
  }

  Future<void> loadPickupSpots() async {
    final pickup = state.pickupPlace;
    if (pickup == null) {
      state = state.copyWith(pickupSpots: const []);
      return;
    }
    state = state.copyWith(isLoadingPickupSpots: true, clearError: true);
    try {
      final spots = await ref
          .read(rideBookingRepositoryProvider)
          .fetchPickupSpots(
            lat: pickup.latitude,
            lng: pickup.longitude,
            address: pickup.address,
          );
      final effective = spots.isNotEmpty
          ? spots
          : [
              PickupSpotEntity(
                index: 0,
                label: pickup.label,
                address: pickup.address,
                latitude: pickup.latitude,
                longitude: pickup.longitude,
                source: 'selected_location',
              ),
            ];
      state = state.copyWith(
        isLoadingPickupSpots: false,
        pickupSpots: effective,
        selectedPickupSpotIndex: 0,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingPickupSpots: false,
        pickupSpots: [
          PickupSpotEntity(
            index: 0,
            label: pickup.label,
            address: pickup.address,
            latitude: pickup.latitude,
            longitude: pickup.longitude,
            source: 'selected_location',
          ),
        ],
        selectedPickupSpotIndex: 0,
      );
    }
  }

  void updatePaymentMethod(String method) {
    var label = method.trim();
    if (label.isEmpty || isCashPaymentLabel(label)) {
      label = CardBookingPayment.label;
    }
    ref
        .read(paymentMethodControllerProvider.notifier)
        .selectPaymentMethod(label);
    PaymentMethodEntity? matched;
    for (final item in state.paymentMethods) {
      if (item.label == label || item.code == label) {
        matched = item;
        break;
      }
    }
    final code = isCardPaymentMethodCode(matched?.code)
        ? matched!.code
        : CardBookingPayment.code;
    state = state.copyWith(
      paymentMethod: isCashPaymentLabel(matched?.label) ? label : (matched?.label ?? label),
      paymentMethodCode: code,
      clearError: true,
      clearIdempotencyKey: true,
    );
  }

  void syncPaymentFromProvider() {
    final method = ref
        .read(paymentMethodControllerProvider)
        .selectedPaymentMethod;
    if (method != state.paymentMethod) {
      updatePaymentMethod(method);
    }
  }

  void selectPickupSpot(int index) {
    state = state.copyWith(selectedPickupSpotIndex: index, clearError: true);
  }

  void continueToRideSelection() {
    if (!state.hasResolvedPickup || !state.hasResolvedDestination) {
      state = state.copyWith(errorMessage: state.unresolvedLocationsMessage());
      return;
    }
    if (state.selectedDestination == null || state.dropoffPlace == null) {
      state = state.copyWith(errorMessage: 'Select a destination first.');
      return;
    }
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.rideSelection,
          extra: RideFlowExtra.buildSelectionExtra(
            selectedType: state.selectedRideType,
            pickupLocation: state.pickupLocation,
            destination: state.selectedDestination,
          ),
        );
  }

  void continueToConfirmPickup() {
    // Prefer direct booking from ride selection when API trip is ready.
    if (state.pickupPlace != null && state.dropoffPlace != null) {
      unawaited(confirmBooking());
      return;
    }
    if (!state.hasSelectedVehicle) {
      state = state.copyWith(errorMessage: 'Select a vehicle to continue.');
      return;
    }
    syncPaymentFromProvider();
    final vehicle = state.selectedVehicle!;
    final payment = state.bookingPaymentLabel;
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.confirmPickup,
          extra: RideFlowExtra.buildConfirmPickupExtra(
            selectedType: state.selectedRideType,
            selectedVehicle: vehicle,
            pickupLocation: state.pickupLocation,
            destination: state.selectedDestination,
            estimatedFare: state.estimatedFare ?? vehicle.price,
            paymentMethod: payment,
          ),
        );
  }

  Future<void> confirmBooking() async {
    StripeDebug.log('Confirm Ride tapped');
    StripeDebug.log('selectedPaymentMethod=${state.paymentMethodCode}');
    if (!state.canConfirmBooking) {
      StripeDebug.log('cardAvailable=unknown');
      StripeDebug.log('bookingRequestWillBeSent=false');
      StripeDebug.log('BOOKING BLOCKED');
      StripeDebug.log('reason=Select a service to continue.');
      state = state.copyWith(errorMessage: 'Select a service to continue.');
      return;
    }
    if (state.isCreatingBooking) {
      StripeDebug.log('bookingRequestWillBeSent=false');
      StripeDebug.log('BOOKING BLOCKED');
      StripeDebug.log('reason=booking already in progress');
      return;
    }
    if (state.isPaymentPending && state.bookingId != null) {
      StripeDebug.log('bookingRequestWillBeSent=false');
      StripeDebug.log('quoted booking detected -> checking Stripe payment status');
      await retryCardPayment();
      return;
    }

    final key = state.idempotencyKey ?? _uuid.v4();
    const paymentCode = CardBookingPayment.code;

    state = state.copyWith(
      isCreatingBooking: true,
      idempotencyKey: key,
      phase: RidePlanningPhase.bookingCreating,
      paymentMethod: state.bookingPaymentLabel,
      paymentMethodCode: paymentCode,
      cardPaymentUiState: CardPaymentUiState.preparing,
      clearError: true,
    );

    try {
      final usable = await _isStripeCardUsable();
      StripeDebug.log('cardAvailable=$usable');
      if (!usable) {
        StripeDebug.log('bookingRequestWillBeSent=false');
        StripeDebug.log('BOOKING BLOCKED');
        StripeDebug.log(
          'reason=${StripeDebug.lastUnavailableReason ?? CardBookingPayment.unavailableMessage}',
        );
        state = state.copyWith(
          isCreatingBooking: false,
          phase: RidePlanningPhase.quoteLoaded,
          cardPaymentUiState: CardPaymentUiState.idle,
          errorMessage: CardBookingPayment.unavailableMessage,
        );
        return;
      }

      StripeDebug.log('bookingRequestWillBeSent=true');
      StripeDebug.log('paymentMethodCode=$paymentCode');

      final result = await ref
          .read(rideBookingRepositoryProvider)
          .createBooking(
            serviceCategoryId: state.selectedVehicleId!,
            pickup: _waypointFromPlace(
              state.pickupPlace!,
              spotLabel: state.pickupSpotLabel.isEmpty
                  ? null
                  : state.pickupSpotLabel,
            ),
            dropoff: _waypointFromPlace(state.dropoffPlace!),
            paymentMethodCode: paymentCode,
            idempotencyKey: key,
          );

      await _applyBookingEntity(result.booking, preserveRoute: true);
      _rememberPayment(result.payment);

      if (_bookingNeedsCardAuthorization(result)) {
        state = state.copyWith(
          isCreatingBooking: false,
          pickupConfirmed: true,
          phase: RidePlanningPhase.paymentPending,
          bookingStatus: result.booking.status,
          clearCancelIdempotencyKey: true,
          cardPaymentUiState: CardPaymentUiState.preparing,
        );
        await _authorizeCardPayment(
          clientSecret: result.payment?.clientSecret,
        );
        return;
      }

      try {
        await _connectAndListen(result.booking.id);
      } catch (_) {
        state = state.copyWith(
          socketStatus: ActiveRideSocketStatus.disconnected,
        );
      }

      state = state.copyWith(
        isCreatingBooking: false,
        pickupConfirmed: true,
        phase: _phaseFromBookingStatus(result.booking.status),
        bookingStatus: result.booking.status,
        searchStartedAt: DateTime.now(),
        clearCancelIdempotencyKey: true,
        cardPaymentUiState: CardPaymentUiState.idle,
        clearBookingPayment: true,
        clearPaymentClientSecret: true,
      );

      _navigateToFindingDriver(result.booking.id);
    } on PassengerApiException catch (e) {
      if (e.code == 'ACTIVE_BOOKING_EXISTS' ||
          e.message.toLowerCase().contains('active booking')) {
        final restored = await restoreActiveBooking(navigate: true);
        state = state.copyWith(
          isCreatingBooking: false,
          errorMessage: restored
              ? null
              : (e.message.isNotEmpty
                    ? e.message
                    : 'You already have an active booking.'),
          clearError: restored,
          phase: restored
              ? state.phase
              : RidePlanningPhase.error,
          cardPaymentUiState: restored
              ? state.cardPaymentUiState
              : CardPaymentUiState.idle,
        );
        return;
      }
      state = state.copyWith(
        isCreatingBooking: false,
        phase: RidePlanningPhase.error,
        cardPaymentUiState: CardPaymentUiState.idle,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isCreatingBooking: false,
        phase: RidePlanningPhase.error,
        cardPaymentUiState: CardPaymentUiState.idle,
        errorMessage: e is PassengerApiException
            ? e.message
            : 'Could not create booking. Try again.',
      );
    }
  }

  /// Restores an in-progress booking after splash/session restore or conflict.
  /// Prefer [navigate] = false so Home can show the persistent card.
  Future<bool> restoreActiveBooking({bool navigate = false}) async {
    try {
      final booking = await ref
          .read(rideBookingRepositoryProvider)
          .activeBooking();
      if (booking == null || !booking.isActive) return false;

      StripeDebug.log('restore active booking');
      StripeDebug.log('bookingId=${booking.id}');
      StripeDebug.log('bookingStatus=${booking.status}');

      await _applyBookingEntity(booking, preserveRoute: false);

      if (booking.status.toLowerCase() == 'quoted') {
        StripeDebug.log(
          'quoted booking detected -> checking Stripe payment status',
        );
        await _reconcileQuotedBookingPayment();
        return true;
      }

      try {
        await _connectAndListen(booking.id);
      } catch (_) {
        // Keep restored booking even if socket connect fails (offline / tests).
        state = state.copyWith(
          socketStatus: ActiveRideSocketStatus.disconnected,
        );
      }

      state = state.copyWith(
        pickupConfirmed: true,
        clearError: true,
        cardPaymentUiState: CardPaymentUiState.idle,
        clearBookingPayment: true,
        clearPaymentClientSecret: true,
      );
      _ensureSearchStartedAt();

      if (navigate) {
        _navigateForActivePhase(replace: true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Leaves the active-ride screen without cancelling. Keeps booking + socket.
  void minimizeActiveRide() {
    if (kDebugMode) {
      debugPrint(
        'ActiveRide: minimize bookingIdPresent=${state.bookingId != null} '
        'socket=${state.socketStatus.name}',
      );
    }
    ref.read(goRouterProvider).go(RouteNames.home);
  }

  /// Reopens Finding Driver / Driver Found for the current active booking.
  void resumeActiveRide({bool replace = false}) {
    if (state.isPaymentPending) {
      unawaited(retryCardPayment());
      return;
    }
    if (!state.hasActiveBooking &&
        state.phase != RidePlanningPhase.expired &&
        state.phase != RidePlanningPhase.noDrivers) {
      return;
    }
    _navigateForActivePhase(replace: replace);
  }

  void markPhaseNavigated(RidePlanningPhase phase) {
    final id = state.bookingId ?? '';
    state = state.copyWith(lastNavigatedPhaseKey: '$id:${phase.name}');
  }

  bool hasNavigatedForPhase(RidePlanningPhase phase) {
    final id = state.bookingId ?? '';
    return state.lastNavigatedPhaseKey == '$id:${phase.name}';
  }

  Future<bool> cancelActiveBooking({String? reason}) async {
    final bookingId = state.bookingId;
    if (bookingId == null || state.isCancelling) return false;

    final key = state.cancelIdempotencyKey ?? _uuid.v4();
    state = state.copyWith(
      isCancelling: true,
      cancelIdempotencyKey: key,
      clearError: true,
    );

    try {
      final updated = await ref
          .read(rideBookingRepositoryProvider)
          .cancelBooking(
            bookingId,
            reason: reason ?? 'Passenger cancelled',
            idempotencyKey: key,
          );
      await _stopLiveUpdates();
      if (updated != null) {
        await _applyBookingEntity(updated, preserveRoute: true);
      }
      _clearActiveBookingFields(phase: RidePlanningPhase.cancelled);
      return true;
    } on PassengerApiException catch (e) {
      final isRateLimited = e.code == 'RATE_LIMITED' || e.statusCode == 429;
      state = state.copyWith(
        isCancelling: false,
        // Keep cancelIdempotencyKey so retry reuses the same key.
        errorMessage: isRateLimited
            ? _rateLimitedCancelMessage(e)
            : (e.message.isNotEmpty ? e.message : 'Cancellation not allowed.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isCancelling: false,
        errorMessage: 'Could not cancel booking. Try again.',
      );
      return false;
    }
  }

  String _rateLimitedCancelMessage(PassengerApiException e) {
    final details = e.details;
    final retry =
        details?['retryAfter'] ??
        details?['retry_after'] ??
        details?['retryAfterSeconds'];
    if (retry != null) {
      return '${e.message} Retry after ${retry}s.';
    }
    return e.message.isNotEmpty
        ? e.message
        : 'Too many requests. Please wait and try again.';
  }

  /// Clears booking identity after a confirmed terminal outcome (cancel/expire).
  void clearTerminalBooking() {
    unawaited(_stopLiveUpdates());
    _clearActiveBookingFields(phase: RidePlanningPhase.initial);
  }

  void dismissExpiredBookingToHome() {
    clearTerminalBooking();
    ref.read(goRouterProvider).go(RouteNames.home);
  }

  void retryAfterExpired() {
    clearTerminalBooking();
    ref.read(goRouterProvider).go(RouteNames.rideSelection);
  }

  void changeServiceAfterExpired() {
    clearTerminalBooking();
    ref.read(goRouterProvider).go(RouteNames.rideSelection);
  }

  void _clearActiveBookingFields({required RidePlanningPhase phase}) {
    state = state.copyWith(
      isCancelling: false,
      clearBookingId: true,
      clearAssignedDriver: true,
      clearDriverLocation: true,
      clearCancelIdempotencyKey: true,
      clearIdempotencyKey: true,
      bookingNumber: '',
      bookingStatus: '',
      phase: phase,
      socketStatus: ActiveRideSocketStatus.idle,
      lastNavigatedPhaseKey: '',
      clearSearchStartedAt: true,
      clearError: true,
      recordingConsentStatus: RecordingConsentStatus.unknown,
      clearRecordingConsentInfo: true,
      clearRecordingConsentError: true,
      clearLastRecordingConsentChoice: true,
      cardPaymentUiState: CardPaymentUiState.idle,
      clearBookingPayment: true,
      clearPaymentClientSecret: true,
      isResolvingPayment: false,
    );
  }

  void _ensureSearchStartedAt() {
    if (state.isSearchingForDriver && state.searchStartedAt == null) {
      state = state.copyWith(searchStartedAt: DateTime.now());
    }
  }

  RidePlanningPhase _phaseFromBookingStatus(String status) {
    return ridePhaseFromBookingStatus(status);
  }

  Future<void> _connectAndListen(String bookingId) async {
    final socket = ref.read(passengerSocketServiceProvider);
    socket.setActiveBookingId(bookingId);
    state = state.copyWith(socketStatus: ActiveRideSocketStatus.connecting);
    await socket.connect();
    await _listenSocket(bookingId);
  }

  Future<void> _stopLiveUpdates() async {
    await _cancelSocketSubscriptions();
    final socket = ref.read(passengerSocketServiceProvider);
    socket.setActiveBookingId(null);
  }

  Future<void> _listenSocket(String bookingId) async {
    await _cancelSocketSubscriptions();
    final socket = ref.read(passengerSocketServiceProvider);

    _socketStatusSub = socket.connectionStatusStream.listen((status) {
      final mapped = switch (status) {
        PassengerSocketConnectionStatus.connecting =>
          ActiveRideSocketStatus.connecting,
        PassengerSocketConnectionStatus.connected =>
          ActiveRideSocketStatus.connected,
        PassengerSocketConnectionStatus.reconnecting =>
          ActiveRideSocketStatus.reconnecting,
        PassengerSocketConnectionStatus.authFailed =>
          ActiveRideSocketStatus.authFailed,
        PassengerSocketConnectionStatus.disconnected =>
          ActiveRideSocketStatus.disconnected,
      };
      final previous = _previousSocketStatus ?? state.socketStatus;
      state = state.copyWith(socketStatus: mapped);
      _previousSocketStatus = mapped;
      final reconnected =
          mapped == ActiveRideSocketStatus.connected &&
          (previous == ActiveRideSocketStatus.reconnecting ||
              previous == ActiveRideSocketStatus.disconnected ||
              previous == ActiveRideSocketStatus.connecting);
      if (reconnected && state.hasActiveBooking) {
        unawaited(refreshRecordingConsentFromBackend());
      }
    });

    _bookingSub = socket.bookingStatusStream.listen((event) {
      _applySocketBookingEvent(event, bookingId);
    });
    _driverSub = socket.driverLocationStream.listen((location) {
      _applyDriverLocation(location, bookingId);
    });
    _recordingSub = socket.recordingEventStream.listen((event) {
      _applyRecordingSocketEvent(event, bookingId);
    });
  }

  void _applySocketBookingEvent(Map<String, dynamic> event, String bookingId) {
    final eventBookingId = event['bookingId']?.toString();
    if (eventBookingId != null &&
        eventBookingId.isNotEmpty &&
        eventBookingId != bookingId) {
      return;
    }

    final eventName = (event['event'] ?? '').toString().toLowerCase();
    var status = (event['status'] ?? '').toString();
    if (status.isEmpty || eventName == 'searching' || eventName == 'accepted') {
      if (eventName == 'searching') status = 'searching';
      if (eventName == 'accepted') status = 'accepted';
      if (eventName == 'expired') status = 'expired';
    }
    if (status.isEmpty) return;

    final phase = _phaseFromBookingStatus(status);
    final driver = RidePlanningParsers.assignedDriver(
      event['driver'] ?? event['assignedDriver'],
    );
    final consentInfo =
        RidePlanningParsers.recordingConsent(event) ??
        state.recordingConsentInfo;

    state = state.copyWith(
      bookingId: bookingId,
      bookingStatus: status,
      phase: phase,
      assignedDriver: driver,
      clearAssignedDriver:
          driver == null && phase == RidePlanningPhase.bookingSearching,
      searchStartedAt:
          phase == RidePlanningPhase.bookingSearching ||
              phase == RidePlanningPhase.bookingOffered
          ? (state.searchStartedAt ?? DateTime.now())
          : state.searchStartedAt,
      recordingConsentInfo: consentInfo,
    );
    _syncRecordingConsentFromInfo(
      consentInfo,
      phase: phase,
      preserveFailed: true,
    );

    if (state.isTerminalRidePhase) {
      unawaited(_stopLiveUpdates());
    }
  }

  void _applyRecordingSocketEvent(
    Map<String, dynamic> event,
    String bookingId,
  ) {
    final eventBookingId =
        event['bookingId']?.toString() ?? event['booking_id']?.toString();
    if (eventBookingId != null &&
        eventBookingId.isNotEmpty &&
        eventBookingId != bookingId) {
      return;
    }
    if (state.bookingId != null && state.bookingId != bookingId) return;

    final eventName = (event['event'] ?? '').toString();
    if (eventName == 'recording:session_available') {
      unawaited(refreshRecordingConsentFromBackend());
      return;
    }

    if (eventName == 'recording:consent_updated') {
      final info = RidePlanningParsers.recordingConsent(event);
      if (info != null) {
        state = state.copyWith(
          recordingConsentInfo: info,
          clearRecordingConsentError: true,
        );
        _syncRecordingConsentFromInfo(info, phase: state.phase);
      } else {
        unawaited(refreshRecordingConsentFromBackend());
      }
    }
  }

  void _syncRecordingConsentFromInfo(
    RecordingConsentInfo? info, {
    required RidePlanningPhase phase,
    bool preserveFailed = false,
  }) {
    final isAssigned =
        phase == RidePlanningPhase.driverAccepted ||
        phase == RidePlanningPhase.driverEnRoute ||
        phase == RidePlanningPhase.driverArrived ||
        phase == RidePlanningPhase.rideInProgress;

    final next = resolveRecordingConsentStatus(
      isAssignedRidePhase: isAssigned,
      info: info,
      preserveTransient: state.recordingConsentStatus ==
              RecordingConsentStatus.submitting
          ? RecordingConsentStatus.submitting
          : (preserveFailed &&
                    state.recordingConsentStatus ==
                        RecordingConsentStatus.failed
                ? RecordingConsentStatus.failed
                : null),
    );

    // Never overwrite an in-flight submit with a stale required signal.
    if (state.recordingConsentStatus == RecordingConsentStatus.submitting &&
        next == RecordingConsentStatus.required) {
      return;
    }

    state = state.copyWith(
      recordingConsentStatus: next,
      recordingConsentInfo: info ?? state.recordingConsentInfo,
      clearRecordingConsentError:
          next == RecordingConsentStatus.granted ||
          next == RecordingConsentStatus.denied ||
          next == RecordingConsentStatus.notRequired,
    );
  }

  /// Submits passenger recording consent. Never auto-grants.
  Future<bool> submitRecordingConsent(bool consent) async {
    final bookingId = state.bookingId;
    if (bookingId == null || bookingId.isEmpty) return false;
    if (!state.isAssignedRidePhase) return false;
    if (state.recordingConsentStatus == RecordingConsentStatus.submitting) {
      return false;
    }
    if (state.recordingConsentStatus == RecordingConsentStatus.granted ||
        state.recordingConsentStatus == RecordingConsentStatus.denied) {
      return true;
    }

    state = state.copyWith(
      recordingConsentStatus: RecordingConsentStatus.submitting,
      lastRecordingConsentChoice: consent,
      clearRecordingConsentError: true,
    );

    try {
      final result = await ref
          .read(rideBookingRepositoryProvider)
          .submitRecordingConsent(bookingId: bookingId, consent: consent);

      if (result.booking != null) {
        await _applyBookingEntity(result.booking!, preserveRoute: true);
      }

      final info = result.asInfo;
      final confirmed = resolveRecordingConsentStatus(
        isAssignedRidePhase: true,
        info: RecordingConsentInfo(
          consentStatus:
              info.consentStatus ?? (consent ? 'granted' : 'denied'),
          recordingConsentedAt: info.recordingConsentedAt,
          consented: info.consented ?? consent,
          required: info.required,
        ),
      );

      state = state.copyWith(
        recordingConsentStatus: confirmed,
        recordingConsentInfo: RecordingConsentInfo(
          consentStatus:
              info.consentStatus ?? (consent ? 'granted' : 'denied'),
          recordingConsentedAt: info.recordingConsentedAt,
          consented: info.consented ?? consent,
          required: info.required,
        ),
        clearRecordingConsentError: true,
      );
      return confirmed == RecordingConsentStatus.granted ||
          confirmed == RecordingConsentStatus.denied;
    } on PassengerApiException catch (e) {
      final alreadyRecorded =
          e.code == 'CONSENT_ALREADY_RECORDED' ||
          e.code == 'RECORDING_CONSENT_ALREADY_SET' ||
          (e.message.toLowerCase().contains('already') &&
              e.message.toLowerCase().contains('consent'));
      if (alreadyRecorded) {
        await refreshRecordingConsentFromBackend();
        return state.recordingConsentStatus ==
                RecordingConsentStatus.granted ||
            state.recordingConsentStatus == RecordingConsentStatus.denied;
      }
      state = state.copyWith(
        recordingConsentStatus: RecordingConsentStatus.failed,
        recordingConsentError: e.message.isNotEmpty
            ? e.message
            : 'Could not save recording preference. Try again.',
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        recordingConsentStatus: RecordingConsentStatus.failed,
        recordingConsentError:
            'Could not save recording preference. Try again.',
      );
      return false;
    }
  }

  Future<bool> retryRecordingConsent() async {
    final choice = state.lastRecordingConsentChoice;
    if (choice == null) return false;
    return submitRecordingConsent(choice);
  }

  /// Refreshes consent from active booking / booking-by-id after restore
  /// or socket reconnect. Does not auto-grant.
  Future<void> refreshRecordingConsentFromBackend() async {
    final bookingId = state.bookingId;
    if (bookingId == null || bookingId.isEmpty) return;
    if (!state.hasActiveBooking && !state.isAssignedRidePhase) return;
    if (_refreshingRecordingConsent) return;
    if (state.recordingConsentStatus == RecordingConsentStatus.submitting) {
      return;
    }

    _refreshingRecordingConsent = true;
    try {
      final repo = ref.read(rideBookingRepositoryProvider);
      BookingEntity? booking = await repo.bookingById(bookingId);
      booking ??= await repo.activeBooking();
      if (booking == null) return;
      if (booking.id != bookingId && state.bookingId != booking.id) return;

      await _applyBookingEntity(booking, preserveRoute: true);
    } catch (_) {
      // Keep last known consent; booking flow must not crash.
    } finally {
      _refreshingRecordingConsent = false;
    }
  }

  void _applyDriverLocation(DriverLocationEntity location, String bookingId) {
    if (location.bookingId != bookingId) return;
    if (state.isTerminalRidePhase) return;
    if (!location.latitude.isFinite || !location.longitude.isFinite) return;
    if (location.latitude == 0 && location.longitude == 0) return;

    if (location.timestamp != null) {
      final ts = DateTime.tryParse(location.timestamp!);
      if (ts != null &&
          _lastDriverLocationAt != null &&
          ts.isBefore(_lastDriverLocationAt!)) {
        return;
      }
      if (ts != null) _lastDriverLocationAt = ts;
    } else {
      _lastDriverLocationAt = DateTime.now();
    }

    state = state.copyWith(driverLocation: location);
  }

  Future<void> _applyBookingEntity(
    BookingEntity booking, {
    required bool preserveRoute,
  }) async {
    PlaceEntity? pickup = state.pickupPlace;
    PlaceEntity? dropoff = state.dropoffPlace;

    if (booking.pickupLatitude != null &&
        booking.pickupLongitude != null &&
        booking.pickupLatitude!.isFinite &&
        booking.pickupLongitude!.isFinite) {
      pickup = PlaceEntity(
        placeId: pickup?.placeId ?? '',
        label: booking.pickupAddress ?? pickup?.label ?? 'Pickup',
        address: booking.pickupAddress ?? pickup?.address ?? '',
        latitude: booking.pickupLatitude!,
        longitude: booking.pickupLongitude!,
      );
    }

    if (booking.dropoffLatitude != null &&
        booking.dropoffLongitude != null &&
        booking.dropoffLatitude!.isFinite &&
        booking.dropoffLongitude!.isFinite) {
      dropoff = PlaceEntity(
        placeId: dropoff?.placeId ?? '',
        label: booking.dropoffAddress ?? dropoff?.label ?? 'Destination',
        address: booking.dropoffAddress ?? dropoff?.address ?? '',
        latitude: booking.dropoffLatitude!,
        longitude: booking.dropoffLongitude!,
      );
    }

    List<({double lat, double lng})> points = state.polylinePoints;
    RoutePreviewEntity? route = preserveRoute ? state.routePreview : null;
    if (!preserveRoute || points.isEmpty) {
      final encoded = booking.encodedPolyline;
      if (encoded != null && encoded.isNotEmpty) {
        points = EncodedPolylineDecoder.decode(encoded);
        route = state.routePreview;
      }
    }

    final fare = booking.formattedFare ?? state.estimatedFare;

    RideVehicleOption? vehicle = state.selectedVehicle;
    if (vehicle == null && booking.serviceCategoryId != null) {
      vehicle = RideOptionEntity(
        id: booking.serviceCategoryId!,
        name: booking.serviceName ?? 'Ride',
        category: 'recommended',
        time: '',
        description: booking.status,
        price: fare ?? '',
      );
    }

    final nextPhase = _phaseFromBookingStatus(booking.status);
    state = state.copyWith(
      bookingId: booking.id,
      bookingNumber: booking.bookingNumber,
      bookingStatus: booking.status,
      phase: nextPhase,
      pickupPlace: pickup,
      dropoffPlace: dropoff,
      pickupLocation:
          pickup?.label ?? booking.pickupAddress ?? state.pickupLocation,
      estimatedFare: fare,
      fareCurrency: booking.currency ?? state.fareCurrency,
      paymentMethodCode: booking.paymentMethodCode ?? state.paymentMethodCode,
      assignedDriver: booking.driver,
      clearAssignedDriver: booking.driver == null,
      selectedVehicle: vehicle,
      selectedVehicleId: vehicle?.id ?? booking.serviceCategoryId,
      polylinePoints: points,
      routePreview: route ?? state.routePreview,
      clearDriverLocation:
          nextPhase == RidePlanningPhase.completed ||
          nextPhase == RidePlanningPhase.cancelled ||
          nextPhase == RidePlanningPhase.expired ||
          nextPhase == RidePlanningPhase.noDrivers,
      searchStartedAt:
          nextPhase == RidePlanningPhase.bookingSearching ||
              nextPhase == RidePlanningPhase.bookingOffered
          ? (state.searchStartedAt ?? DateTime.now())
          : state.searchStartedAt,
      recordingConsentInfo:
          booking.recordingConsent ?? state.recordingConsentInfo,
    );
    _syncRecordingConsentFromInfo(
      booking.recordingConsent ?? state.recordingConsentInfo,
      phase: nextPhase,
    );
  }

  void _navigateForActivePhase({bool replace = false}) {
    if (state.isPaymentPending) {
      return;
    }
    final vehicle =
        state.selectedVehicle ??
        RideOptionEntity(
          id: state.bookingId ?? 'active',
          name: state.assignedDriver?.vehicleName ?? 'Active ride',
          category: 'recommended',
          time: '',
          description: state.bookingStatus ?? '',
          price: state.estimatedFare ?? '',
        );
    final extra = RideFlowExtra.buildDriverFoundExtra(
      selectedType: state.selectedRideType,
      selectedVehicle: vehicle,
      pickupLocation: state.pickupLocation,
      destination: state.selectedDestination,
      estimatedFare: state.estimatedFare ?? vehicle.price,
      paymentMethod: state.paymentMethod,
      pickupSpotName: state.pickupSpotLabel,
      bookingId: state.bookingId,
    );

    final router = ref.read(goRouterProvider);
    final target =
        state.isAssignedRidePhase ||
            state.phase == RidePlanningPhase.rideInProgress
        ? RouteNames.driverFound
        : RouteNames.findingDriver;

    markPhaseNavigated(state.phase);
    if (replace) {
      router.go(target, extra: extra);
    } else {
      router.pushReplacement(target, extra: extra);
    }
  }

  Future<void> confirmPickup() async {
    if (state.pickupPlace != null && state.dropoffPlace != null) {
      await confirmBooking();
      return;
    }
    state = state.copyWith(
      errorMessage: 'Pickup and destination are required to book.',
    );
  }

  void addStop() {
    // Multi-stop supported by API payload; UI wiring pending product design.
  }

  void searchDifferentCity() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.citySearch);
  }

  void setLocationOnMap() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.setLocationMap);
  }

  void openSavedPlaces() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.savedPlaces);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetPlanningSession() {
    _locationBootstrapStarted = false;
    _lastDriverLocationAt = null;
    unawaited(_stopLiveUpdates());
    state = state.copyWith(
      clearSelectedDestination: true,
      clearDropoff: true,
      clearRoute: true,
      clearIdempotencyKey: true,
      clearCancelIdempotencyKey: true,
      clearBookingId: true,
      clearAssignedDriver: true,
      clearDriverLocation: true,
      clearEstimatedFare: true,
      clearSearchStartedAt: true,
      predictions: const [],
      rideOptions: const [],
      pickupSpots: const [],
      clearSelectedVehicle: true,
      bookingNumber: '',
      bookingStatus: '',
      phase: RidePlanningPhase.initial,
      socketStatus: ActiveRideSocketStatus.idle,
      lastNavigatedPhaseKey: '',
      cardPaymentUiState: CardPaymentUiState.idle,
      clearBookingPayment: true,
      clearPaymentClientSecret: true,
      isResolvingPayment: false,
    );
  }

  ({List<PaymentMethodEntity> methods, String label, String code})
  _cardPaymentSelection(List<PaymentMethodEntity> backend) {
    final visible = CardBookingPayment.visibleForBooking(backend);
    final selected = visible.first;
    ref
        .read(paymentMethodControllerProvider.notifier)
        .selectPaymentMethod(selected.label);
    StripeDebug.paymentMethodsParsed(
      codes: backend.map((m) => m.code).toList(),
      cardReturnedByBackend: CardBookingPayment.backendIncludesCard(backend),
      selectedPaymentMethod: CardBookingPayment.code,
    );
    return (
      methods: visible,
      label: selected.label,
      code: CardBookingPayment.code,
    );
  }

  Future<bool> _isStripeCardUsable() async {
    StripeDebug.resetAvailability();
    final ready = await _loadPaymentConfigQuietly();
    if (!ready) {
      StripeDebug.dumpCardAvailability(finalCardAvailable: false);
      return false;
    }
    try {
      final methods = await ref
          .read(rideBookingRepositoryProvider)
          .paymentMethods();
      final hasCard = CardBookingPayment.backendIncludesCard(methods);
      StripeDebug.lastBackendReturnedCard = hasCard;
      if (!hasCard) {
        StripeDebug.lastUnavailableReason = 'card missing from payment-methods';
      }
      StripeDebug.dumpCardAvailability(finalCardAvailable: hasCard);
      return hasCard;
    } catch (e) {
      StripeDebug.lastBackendReturnedCard = false;
      StripeDebug.lastUnavailableReason = 'payment methods request failed';
      StripeDebug.log(
        'error=${StripeDebug.redactSecretsInText(e.toString())}',
      );
      StripeDebug.dumpCardAvailability(finalCardAvailable: false);
      return false;
    }
  }

  Future<bool> _loadPaymentConfigQuietly() async {
    try {
      final config = await ref
          .read(rideBookingRepositoryProvider)
          .paymentConfig();
      final key = config.publishableKey?.trim() ?? '';
      StripeDebug.lastStripeEnabled = config.stripeEnabled;
      StripeDebug.lastCardEnabled = config.cardEnabled;
      StripeDebug.lastPublishableKeyValid = key.startsWith('pk_');
      if (!config.canInitializeStripe) {
        state = state.copyWith(stripeReady: false);
        StripeDebug.lastStripeSdkInitialized = false;
        if (!config.cardEnabled) {
          StripeDebug.lastUnavailableReason = 'cardEnabled=false';
        } else if (key.isEmpty) {
          StripeDebug.lastUnavailableReason = 'publishable key missing';
        } else if (!key.startsWith('pk_')) {
          StripeDebug.lastUnavailableReason = 'invalid pk_ prefix';
        } else {
          StripeDebug.lastUnavailableReason = 'canInitializeStripe=false';
        }
        return false;
      }
      final ready = await ref
          .read(stripePaymentGatewayProvider)
          .initialize(publishableKey: config.publishableKey!);
      StripeDebug.lastStripeSdkInitialized = ready;
      state = state.copyWith(stripeReady: ready);
      if (!ready) {
        StripeDebug.lastUnavailableReason = 'Stripe SDK initialization failed';
      }
      return ready;
    } catch (e) {
      StripeDebug.lastStripeSdkInitialized = false;
      StripeDebug.lastUnavailableReason = 'config request failed';
      StripeDebug.log('Stripe: payment config unavailable');
      StripeDebug.log(
        'error=${StripeDebug.redactSecretsInText(e.toString())}',
      );
      state = state.copyWith(stripeReady: false);
      return false;
    }
  }

  bool _bookingNeedsCardAuthorization(CreateBookingResult result) {
    final booking = result.booking;
    final payment = result.payment;
    final isCard =
        isCardPaymentMethodCode(booking.paymentMethodCode) ||
        isCardPaymentMethodCode(state.paymentMethodCode) ||
        (payment != null && payment.isCard);
    if (!isCard) return false;
    if (booking.status.toLowerCase() == 'quoted') return true;
    if (payment != null && payment.needsPayment) return true;
    return false;
  }

  void _rememberPayment(BookingPaymentEntity? payment) {
    if (payment == null) {
      state = state.copyWith(
        clearBookingPayment: true,
        clearPaymentClientSecret: true,
      );
      return;
    }
    state = state.copyWith(
      bookingPayment: payment,
      paymentClientSecret: payment.hasClientSecret
          ? payment.clientSecret
          : state.paymentClientSecret,
      clearPaymentClientSecret:
          !payment.hasClientSecret && payment.isAuthorized,
    );
  }

  Future<void> retryCardPayment() async {
    final bookingId = state.bookingId;
    if (bookingId == null || bookingId.isEmpty) return;
    if (_authorizingPayment) return;

    state = state.copyWith(
      isResolvingPayment: true,
      cardPaymentUiState: CardPaymentUiState.preparing,
      clearError: true,
    );

    try {
      await _loadPaymentConfigQuietly();
      final payment = await ref
          .read(rideBookingRepositoryProvider)
          .bookingPayment(bookingId);
      _rememberPayment(payment);

      if (payment.isAuthorized) {
        StripeDebug.log('AUTHORIZED -> refresh booking');
        await _refreshBookingAfterAuthorization();
        return;
      }
      if (payment.isCancelled) {
        StripeDebug.log('PAYMENT CANCELLED');
        state = state.copyWith(
          isResolvingPayment: false,
          cardPaymentUiState: CardPaymentUiState.failed,
          errorMessage: 'This payment was cancelled.',
        );
        return;
      }
      if (!payment.needsPayment && payment.isFailed) {
        if (!payment.hasClientSecret &&
            (state.paymentClientSecret == null ||
                state.paymentClientSecret!.isEmpty)) {
          StripeDebug.log('PAYMENT FAILED');
          state = state.copyWith(
            isResolvingPayment: false,
            cardPaymentUiState: CardPaymentUiState.failed,
            errorMessage: 'Payment failed. You can retry or cancel this ride.',
          );
          return;
        }
      }
      if (!payment.hasClientSecret &&
          (state.paymentClientSecret == null ||
              state.paymentClientSecret!.isEmpty)) {
        state = state.copyWith(
          isResolvingPayment: false,
          cardPaymentUiState: CardPaymentUiState.failed,
          errorMessage: 'Payment is still required. Try again in a moment.',
        );
        return;
      }

      state = state.copyWith(
        isResolvingPayment: false,
        phase: RidePlanningPhase.paymentPending,
      );
      await _authorizeCardPayment(clientSecret: payment.clientSecret);
    } on PassengerApiException catch (e) {
      state = state.copyWith(
        isResolvingPayment: false,
        cardPaymentUiState: CardPaymentUiState.failed,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isResolvingPayment: false,
        cardPaymentUiState: CardPaymentUiState.failed,
        errorMessage: 'Could not load payment. Try again.',
      );
    }
  }

  Future<void> _authorizeCardPayment({String? clientSecret}) async {
    final bookingId = state.bookingId;
    if (bookingId == null || bookingId.isEmpty) return;
    if (_authorizingPayment) return;
    _authorizingPayment = true;

    var secret = (clientSecret ?? state.paymentClientSecret)?.trim() ?? '';
    try {
      if (secret.isEmpty) {
        final payment = await ref
            .read(rideBookingRepositoryProvider)
            .bookingPayment(bookingId);
        _rememberPayment(payment);
        secret = payment.clientSecret?.trim() ?? '';
      }
      if (secret.isEmpty) {
        state = state.copyWith(
          phase: RidePlanningPhase.paymentPending,
          cardPaymentUiState: CardPaymentUiState.failed,
          errorMessage: 'Payment is still required. Try again.',
        );
        return;
      }

      if (!state.stripeReady) {
        final ready = await _loadPaymentConfigQuietly();
        if (!ready) {
          StripeDebug.lastUnavailableReason ??=
              'Stripe SDK initialization failed';
          StripeDebug.dumpCardAvailability(finalCardAvailable: false);
          state = state.copyWith(
            phase: RidePlanningPhase.paymentPending,
            cardPaymentUiState: CardPaymentUiState.failed,
            errorMessage: CardBookingPayment.unavailableMessage,
          );
          return;
        }
      }

      state = state.copyWith(
        phase: RidePlanningPhase.paymentPending,
        cardPaymentUiState: CardPaymentUiState.presentingSheet,
        paymentClientSecret: secret,
        clearError: true,
      );

      final outcome = await ref
          .read(stripePaymentGatewayProvider)
          .presentPaymentSheet(
            clientSecret: secret,
            merchantDisplayName: RyduPayments.merchantDisplayName,
          );

      if (outcome == StripeSheetOutcome.canceled) {
        state = state.copyWith(
          phase: RidePlanningPhase.paymentPending,
          cardPaymentUiState: CardPaymentUiState.requiresAction,
          errorMessage: 'Payment was cancelled. Retry when you are ready.',
        );
        return;
      }
      if (outcome == StripeSheetOutcome.failed) {
        state = state.copyWith(
          phase: RidePlanningPhase.paymentPending,
          cardPaymentUiState: CardPaymentUiState.failed,
          errorMessage: 'Payment failed. You can retry or cancel this ride.',
        );
        return;
      }

      state = state.copyWith(
        phase: RidePlanningPhase.paymentPending,
        cardPaymentUiState: CardPaymentUiState.authorizing,
        clearError: true,
      );

      final polled = await _pollPaymentUntilTerminal(bookingId);
      if (polled == null) {
        state = state.copyWith(
          phase: RidePlanningPhase.paymentPending,
          cardPaymentUiState: CardPaymentUiState.requiresAction,
          errorMessage:
              'Payment is still being confirmed. Retry in a moment.',
        );
        return;
      }

      _rememberPayment(polled);

      if (polled.isAuthorized) {
        StripeDebug.log('AUTHORIZED -> refresh booking');
        await _refreshBookingAfterAuthorization();
        return;
      }
      if (polled.requiresAction || polled.needsPayment) {
        state = state.copyWith(
          phase: RidePlanningPhase.paymentPending,
          cardPaymentUiState: CardPaymentUiState.requiresAction,
          errorMessage: 'Additional authentication is required. Retry payment.',
        );
        return;
      }
      if (polled.isCancelled) {
        StripeDebug.log('PAYMENT CANCELLED');
        state = state.copyWith(
          phase: RidePlanningPhase.paymentPending,
          cardPaymentUiState: CardPaymentUiState.failed,
          errorMessage: 'This payment was cancelled.',
        );
        return;
      }
      StripeDebug.log('PAYMENT FAILED');
      state = state.copyWith(
        phase: RidePlanningPhase.paymentPending,
        cardPaymentUiState: CardPaymentUiState.failed,
        errorMessage: 'Payment failed. You can retry or cancel this ride.',
      );
    } catch (e) {
      state = state.copyWith(
        phase: RidePlanningPhase.paymentPending,
        cardPaymentUiState: CardPaymentUiState.failed,
        errorMessage: e is PassengerApiException
            ? e.message
            : 'Payment could not be completed. Try again.',
      );
    } finally {
      _authorizingPayment = false;
    }
  }

  Future<BookingPaymentEntity?> _pollPaymentUntilTerminal(
    String bookingId,
  ) async {
    final delay = ref.read(paymentPollDelayProvider);
    final started = DateTime.now();
    BookingPaymentEntity? latest;
    for (var i = 0; i < PaymentAuthorizationPoller.intervals.length; i++) {
      final wait = PaymentAuthorizationPoller.intervals[i];
      if (wait > Duration.zero) {
        await delay(wait);
      }
      if (DateTime.now().difference(started) >
          PaymentAuthorizationPoller.timeout) {
        break;
      }
      StripeDebug.pollAttempt = i + 1;
      try {
        latest = await ref
            .read(rideBookingRepositoryProvider)
            .bookingPayment(bookingId);
        _rememberPayment(latest);
        if (latest.isTerminal) {
          if (latest.isAuthorized) {
            StripeDebug.log('AUTHORIZED -> refresh booking');
          } else if (latest.isCancelled) {
            StripeDebug.log('PAYMENT CANCELLED');
          } else if (latest.isFailed) {
            StripeDebug.log('PAYMENT FAILED');
          }
          return latest;
        }
      } catch (e) {
        StripeDebug.log('payment poll retry');
        StripeDebug.log(
          'error=${StripeDebug.redactSecretsInText(e.toString())}',
        );
      } finally {
        StripeDebug.pollAttempt = null;
      }
    }
    return latest;
  }

  Future<void> _refreshBookingAfterAuthorization() async {
    final bookingId = state.bookingId;
    if (bookingId == null) return;
    StripeDebug.log('refreshing active booking');
    try {
      final repo = ref.read(rideBookingRepositoryProvider);
      BookingEntity? booking = await repo.bookingById(bookingId);
      booking ??= await repo.activeBooking();
      if (booking == null) {
        StripeDebug.log('bookingStatus=missing');
        state = state.copyWith(
          cardPaymentUiState: CardPaymentUiState.authorized,
          errorMessage: 'Payment authorized. Waiting for dispatch.',
        );
        return;
      }
      StripeDebug.log('bookingStatus=${booking.status}');
      if (booking.status.toLowerCase() == 'quoted') {
        StripeDebug.log(
          'WARNING: payment authorized but booking still quoted',
        );
      }
      await _applyBookingEntity(booking, preserveRoute: true);
      final phase = _phaseFromBookingStatus(booking.status);
      if (phase == RidePlanningPhase.bookingSearching ||
          phase == RidePlanningPhase.bookingOffered ||
          phase == RidePlanningPhase.driverAccepted ||
          phase == RidePlanningPhase.driverEnRoute ||
          phase == RidePlanningPhase.driverArrived ||
          phase == RidePlanningPhase.rideInProgress) {
        state = state.copyWith(
          cardPaymentUiState: CardPaymentUiState.authorized,
          clearPaymentClientSecret: true,
          clearError: true,
        );
        try {
          await _connectAndListen(booking.id);
        } catch (_) {
          state = state.copyWith(
            socketStatus: ActiveRideSocketStatus.disconnected,
          );
        }
        _ensureSearchStartedAt();
        _navigateToFindingDriver(booking.id);
        return;
      }

      state = state.copyWith(
        phase: RidePlanningPhase.paymentPending,
        cardPaymentUiState: CardPaymentUiState.authorized,
        errorMessage: 'Payment authorized. Waiting for dispatch.',
      );
    } catch (_) {
      state = state.copyWith(
        phase: RidePlanningPhase.paymentPending,
        cardPaymentUiState: CardPaymentUiState.authorized,
        errorMessage: 'Payment authorized. Waiting for dispatch.',
      );
    }
  }

  Future<void> _reconcileQuotedBookingPayment() async {
    final bookingId = state.bookingId;
    if (bookingId == null) return;

    state = state.copyWith(
      pickupConfirmed: true,
      phase: RidePlanningPhase.paymentPending,
      cardPaymentUiState: CardPaymentUiState.preparing,
      clearError: true,
    );

    unawaited(_loadPaymentConfigQuietly());

    try {
      final payment = await ref
          .read(rideBookingRepositoryProvider)
          .bookingPayment(bookingId);
      _rememberPayment(payment);

      if (payment.isAuthorized) {
        StripeDebug.log('AUTHORIZED -> refresh booking');
        await _refreshBookingAfterAuthorization();
        return;
      }
      if (payment.isCancelled) {
        StripeDebug.log('PAYMENT CANCELLED');
        state = state.copyWith(
          cardPaymentUiState: CardPaymentUiState.failed,
          errorMessage: 'This payment was cancelled.',
        );
        return;
      }
      if (payment.isFailed) {
        StripeDebug.log('PAYMENT FAILED');
        state = state.copyWith(
          cardPaymentUiState: CardPaymentUiState.failed,
          errorMessage: 'Payment failed. You can retry or cancel this ride.',
        );
        return;
      }

      state = state.copyWith(
        phase: RidePlanningPhase.paymentPending,
        cardPaymentUiState: payment.requiresAction
            ? CardPaymentUiState.requiresAction
            : CardPaymentUiState.requiresAction,
        errorMessage: payment.requiresAction
            ? 'Additional authentication is required. Retry payment.'
            : null,
        clearError: !payment.requiresAction,
      );
    } catch (_) {
      state = state.copyWith(
        phase: RidePlanningPhase.paymentPending,
        cardPaymentUiState: CardPaymentUiState.requiresAction,
        errorMessage: 'Complete payment to find a driver.',
      );
    }
  }

  void _navigateToFindingDriver(String bookingId) {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      _navigateForActivePhase();
      return;
    }
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.findingDriver,
          extra: RideFlowExtra.buildDriverFoundExtra(
            selectedType: state.selectedRideType,
            selectedVehicle: vehicle,
            pickupLocation: state.pickupLocation,
            destination: state.selectedDestination,
            estimatedFare: state.estimatedFare ?? vehicle.price,
            paymentMethod: state.paymentMethod,
            pickupSpotName: state.pickupSpotLabel,
            bookingId: bookingId,
          ),
        );
  }

  LatLngWaypoint _waypointFromPlace(PlaceEntity place, {String? spotLabel}) {
    return LatLngWaypoint(
      latitude: place.latitude,
      longitude: place.longitude,
      address: place.address,
      placeId: place.placeId.isEmpty ? null : place.placeId,
      spotLabel: spotLabel,
    );
  }
}
