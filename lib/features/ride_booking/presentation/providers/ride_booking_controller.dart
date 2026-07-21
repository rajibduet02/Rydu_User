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
import '../../../payment/presentation/providers/payment_method_provider.dart';
import '../../data/utils/ride_planning_parsers.dart';
import '../../../../core/network/passenger_socket_service.dart';
import '../../domain/constants/ride_booking_type_ids.dart';
import '../../domain/entities/pickup_spot_entity.dart';
import '../../domain/entities/ride_planning_entities.dart';
import '../models/ride_flow_extra.dart';
import '../models/ride_vehicle_option.dart';
import '../models/suggested_location.dart';
import 'ride_booking_dependencies.dart';

export '../../domain/constants/ride_booking_type_ids.dart';

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
    this.paymentMethod = '',
    this.paymentMethodCode = '',
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
      (isSearchingForDriver || isAssignedRidePhase);

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

  String get activeRideStatusLabel {
    return switch (phase) {
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
      (isSearchingForDriver || phase == RidePlanningPhase.driverAccepted);

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
    );
  }
}

RidePlanningPhase ridePhaseFromBookingStatus(String status) {
  return switch (status.toLowerCase()) {
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
  StreamSubscription<PassengerSocketConnectionStatus>? _socketStatusSub;
  bool _locationBootstrapStarted = false;
  DateTime? _lastDriverLocationAt;
  PlaceEntity? _previousResolvedPickup;
  PickupSource _previousPickupSource = PickupSource.none;
  int _routeQuoteActionId = 0;
  bool _navigatingToSelection = false;
  bool suppressPickupTextInvalidation = false;

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

  Future<void> _cancelSocketSubscriptions() async {
    await _bookingSub?.cancel();
    await _driverSub?.cancel();
    await _socketStatusSub?.cancel();
    _bookingSub = null;
    _driverSub = null;
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
      paymentMethod: paymentMethod ?? state.paymentMethod,
      paymentMethodCode: state.paymentMethodCode.isNotEmpty
          ? state.paymentMethodCode
          : 'cash',
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
    final payment = RideFlowExtra.stringFrom(extra['paymentMethod'], 'Cash');
    ref
        .read(paymentMethodControllerProvider.notifier)
        .selectPaymentMethod(payment);
    final spotIndex = extra['selectedPickupSpotIndex'] as int? ?? 0;

    state = state.copyWith(
      selectedRideType: type,
      pickupLocation: pickup,
      destinationQuery: destination?.name ?? state.destinationQuery,
      selectedDestination: destination,
      selectedVehicleId: vehicleId ?? vehicle?.id,
      selectedVehicle: vehicle,
      estimatedFare: fare ?? vehicle?.price,
      paymentMethod: payment,
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

    if (kDebugMode) {
      debugPrint(
        'PassengerAutocomplete: start input="$input" field=${field.name} '
        'requestId=$requestId',
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
            country: 'BD',
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

      PaymentMethodEntity? defaultMethod;
      for (final m in methods) {
        if (m.isDefault) {
          defaultMethod = m;
          break;
        }
      }
      defaultMethod ??= methods.isNotEmpty ? methods.first : null;
      final paymentLabel = defaultMethod?.label ?? '';
      final paymentCode = defaultMethod?.code ?? '';
      if (paymentLabel.isNotEmpty) {
        ref
            .read(paymentMethodControllerProvider.notifier)
            .selectPaymentMethod(paymentLabel);
      }

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
        paymentMethods: methods,
        paymentMethod: paymentLabel,
        paymentMethodCode: paymentCode,
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
      PaymentMethodEntity? defaultMethod;
      for (final m in methods) {
        if (m.isDefault) {
          defaultMethod = m;
          break;
        }
      }
      defaultMethod ??= methods.isNotEmpty ? methods.first : null;
      final paymentLabel = defaultMethod?.label ?? '';
      final paymentCode = defaultMethod?.code ?? '';
      if (paymentLabel.isNotEmpty) {
        ref
            .read(paymentMethodControllerProvider.notifier)
            .selectPaymentMethod(paymentLabel);
      }

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
        paymentMethods: methods,
        paymentMethod: paymentLabel,
        paymentMethodCode: paymentCode,
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
    ref
        .read(paymentMethodControllerProvider.notifier)
        .selectPaymentMethod(method);
    PaymentMethodEntity? matched;
    for (final item in state.paymentMethods) {
      if (item.label == method || item.code == method) {
        matched = item;
        break;
      }
    }
    state = state.copyWith(
      paymentMethod: method,
      paymentMethodCode: matched?.code ?? method.toLowerCase(),
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
    final payment = ref
        .read(paymentMethodControllerProvider)
        .selectedPaymentMethod;
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
    if (!state.canConfirmBooking) {
      state = state.copyWith(errorMessage: 'Select a service to continue.');
      return;
    }
    if (state.isCreatingBooking) return;

    final key = state.idempotencyKey ?? _uuid.v4();
    state = state.copyWith(
      isCreatingBooking: true,
      idempotencyKey: key,
      phase: RidePlanningPhase.bookingCreating,
      clearError: true,
    );

    try {
      final booking = await ref
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
            paymentMethodCode: state.paymentMethodCode,
            idempotencyKey: key,
          );

      await _applyBookingEntity(booking, preserveRoute: true);
      await _connectAndListen(booking.id);

      state = state.copyWith(
        isCreatingBooking: false,
        pickupConfirmed: true,
        phase: _phaseFromBookingStatus(booking.status),
        bookingStatus: booking.status,
        searchStartedAt: DateTime.now(),
        clearCancelIdempotencyKey: true,
      );

      final vehicle = state.selectedVehicle!;
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
              bookingId: booking.id,
            ),
          );
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
              ? RidePlanningPhase.bookingSearching
              : RidePlanningPhase.error,
        );
        return;
      }
      state = state.copyWith(
        isCreatingBooking: false,
        phase: RidePlanningPhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isCreatingBooking: false,
        phase: RidePlanningPhase.error,
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

      await _applyBookingEntity(booking, preserveRoute: false);
      try {
        await _connectAndListen(booking.id);
      } catch (_) {
        // Keep restored booking even if socket connect fails (offline / tests).
        state = state.copyWith(
          socketStatus: ActiveRideSocketStatus.disconnected,
        );
      }

      state = state.copyWith(pickupConfirmed: true, clearError: true);
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
      state = state.copyWith(socketStatus: mapped);
    });

    _bookingSub = socket.bookingStatusStream.listen((event) {
      _applySocketBookingEvent(event, bookingId);
    });
    _driverSub = socket.driverLocationStream.listen((location) {
      _applyDriverLocation(location, bookingId);
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
    );

    if (state.isTerminalRidePhase) {
      unawaited(_stopLiveUpdates());
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
    );
  }

  void _navigateForActivePhase({bool replace = false}) {
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
