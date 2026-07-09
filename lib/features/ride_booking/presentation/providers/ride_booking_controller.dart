import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../payment/presentation/providers/payment_method_provider.dart';
import '../../domain/constants/ride_booking_type_ids.dart';
import '../../domain/entities/ride_booking_entity.dart';
import '../models/ride_flow_extra.dart';
import '../models/ride_vehicle_option.dart';
import '../models/suggested_location.dart';
import 'ride_booking_dependencies.dart';

export '../../domain/constants/ride_booking_type_ids.dart';

class RideBookingState {
  const RideBookingState({
    this.selectedRideType = RideBookingTypeIds.ride,
    this.pickupLocation = '35 Road No. 2',
    this.destinationQuery = '',
    this.selectedDestination,
    this.suggestedLocations = const [],
    this.rideOptions = const [],
    this.selectedVehicleId,
    this.selectedVehicle,
    this.estimatedFare,
    this.paymentMethod = 'Cash',
    this.selectedPickupSpotIndex = 0,
    this.pickupConfirmed = false,
    this.rentalHours,
    this.leaveOption,
    this.rentalVehicle,
    this.rentalPrice,
    this.isLoading = false,
    this.errorMessage,
  });

  final String selectedRideType;
  final String pickupLocation;
  final String destinationQuery;
  final SuggestedLocation? selectedDestination;
  final List<SuggestedLocation> suggestedLocations;
  final List<RideVehicleOption> rideOptions;
  final String? selectedVehicleId;
  final RideVehicleOption? selectedVehicle;
  final String? estimatedFare;
  final String paymentMethod;
  final int selectedPickupSpotIndex;
  final bool pickupConfirmed;
  final int? rentalHours;
  final String? leaveOption;
  final String? rentalVehicle;
  final double? rentalPrice;
  final bool isLoading;
  final String? errorMessage;

  bool get hasSelectedVehicle =>
      selectedVehicleId != null && selectedVehicle != null;

  RideBookingState copyWith({
    String? selectedRideType,
    String? pickupLocation,
    String? destinationQuery,
    SuggestedLocation? selectedDestination,
    bool clearSelectedDestination = false,
    List<SuggestedLocation>? suggestedLocations,
    List<RideVehicleOption>? rideOptions,
    String? selectedVehicleId,
    RideVehicleOption? selectedVehicle,
    bool clearSelectedVehicle = false,
    String? estimatedFare,
    String? paymentMethod,
    int? selectedPickupSpotIndex,
    bool? pickupConfirmed,
    int? rentalHours,
    bool clearRentalContext = false,
    String? leaveOption,
    String? rentalVehicle,
    double? rentalPrice,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RideBookingState(
      selectedRideType: selectedRideType ?? this.selectedRideType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationQuery: destinationQuery ?? this.destinationQuery,
      selectedDestination: clearSelectedDestination
          ? null
          : (selectedDestination ?? this.selectedDestination),
      suggestedLocations: suggestedLocations ?? this.suggestedLocations,
      rideOptions: rideOptions ?? this.rideOptions,
      selectedVehicleId: clearSelectedVehicle
          ? null
          : (selectedVehicleId ?? this.selectedVehicleId),
      selectedVehicle: clearSelectedVehicle
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
      estimatedFare: estimatedFare ?? this.estimatedFare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      selectedPickupSpotIndex:
          selectedPickupSpotIndex ?? this.selectedPickupSpotIndex,
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RideBookingController extends Notifier<RideBookingState> {
  @override
  RideBookingState build() {
    return RideBookingState(
      pickupLocation: ref.read(getDefaultPickupLocationUsecaseProvider).call(),
    );
  }

  Future<void> loadInitialData() async {
    try {
      final pickup = ref.read(getDefaultPickupLocationUsecaseProvider).call();
      final suggestions = await ref
          .read(getSuggestedLocationsUsecaseProvider)
          .call();
      final options = await ref.read(getRideOptionsUsecaseProvider).call();
      state = state.copyWith(
        pickupLocation: pickup,
        suggestedLocations: suggestions,
        rideOptions: options,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Could not load locations.');
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
    final pickup = ref.read(getDefaultPickupLocationUsecaseProvider).call();
    state = RideBookingState(
      selectedRideType: type.isEmpty ? RideBookingTypeIds.ride : type,
      pickupLocation: pickup,
      destinationQuery: '',
      selectedDestination: null,
      suggestedLocations: state.suggestedLocations,
      rentalHours: rentalHours,
      leaveOption: leaveOption,
      rentalVehicle: rentalVehicle,
      rentalPrice: rentalPrice,
      paymentMethod: paymentMethod ?? 'Cash',
      isLoading: false,
      errorMessage: null,
    );
    loadInitialData();
  }

  Future<void> initializeFromExtra(Map<String, dynamic> extra) async {
    final type = RideFlowExtra.stringFrom(
      extra['selectedType'],
      RideBookingTypeIds.ride,
    );
    final pickup = RideFlowExtra.stringFrom(
      extra['pickupLocation'],
      ref.read(getDefaultPickupLocationUsecaseProvider).call(),
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

    RideOptionEntity? resolvedVehicle = vehicle;
    if (resolvedVehicle == null && vehicleId != null) {
      resolvedVehicle = await ref
          .read(selectRideOptionUsecaseProvider)
          .call(vehicleId);
    }

    if (state.rideOptions.isEmpty) {
      await loadInitialData();
    }
    state = state.copyWith(
      selectedRideType: type,
      pickupLocation: pickup,
      destinationQuery: destination?.name ?? state.destinationQuery,
      selectedDestination: destination,
      selectedVehicleId: vehicleId ?? resolvedVehicle?.id,
      selectedVehicle: resolvedVehicle,
      estimatedFare: fare ?? resolvedVehicle?.price,
      paymentMethod: payment,
      selectedPickupSpotIndex: spotIndex,
      clearError: true,
    );
  }

  void updatePickupLocation(String value) {
    state = state.copyWith(pickupLocation: value, clearError: true);
  }

  void updateDestinationQuery(String value) {
    state = state.copyWith(destinationQuery: value, clearError: true);
  }

  Future<void> selectDestination(String locationId) async {
    final found = await ref
        .read(selectDestinationUsecaseProvider)
        .call(locationId);
    state = state.copyWith(
      selectedDestination: found,
      destinationQuery: found?.name ?? state.destinationQuery,
      clearError: true,
    );
  }

  Future<void> selectVehicle(String vehicleId) async {
    final found = await ref
        .read(selectRideOptionUsecaseProvider)
        .call(vehicleId);
    if (found == null) return;
    state = state.copyWith(
      selectedVehicleId: vehicleId,
      selectedVehicle: found,
      estimatedFare: found.price,
      clearError: true,
    );
  }

  void updatePaymentMethod(String method) {
    ref
        .read(paymentMethodControllerProvider.notifier)
        .selectPaymentMethod(method);
    state = state.copyWith(paymentMethod: method, clearError: true);
  }

  void syncPaymentFromProvider() {
    final method = ref
        .read(paymentMethodControllerProvider)
        .selectedPaymentMethod;
    if (method != state.paymentMethod) {
      state = state.copyWith(paymentMethod: method, clearError: true);
    }
  }

  void selectPickupSpot(int index) {
    state = state.copyWith(selectedPickupSpotIndex: index, clearError: true);
  }

  void continueToRideSelection() {
    if (state.selectedDestination == null) {
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

  RideBookingEntity _currentBookingEntity() {
    return RideBookingEntity(
      rideType: state.selectedRideType,
      pickupLocation: state.pickupLocation,
      destination: state.selectedDestination,
      selectedOption: state.selectedVehicle,
      estimatedFare: state.estimatedFare ?? state.selectedVehicle?.price,
      paymentMethod: state.paymentMethod,
      pickupSpotIndex: state.selectedPickupSpotIndex,
      pickupConfirmed: state.pickupConfirmed,
    );
  }

  Future<void> confirmPickup() async {
    if (!state.hasSelectedVehicle) {
      state = state.copyWith(errorMessage: 'Select a vehicle first.');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(confirmPickupUsecaseProvider)
          .call(_currentBookingEntity());
      await ref
          .read(createRideRequestUsecaseProvider)
          .call(_currentBookingEntity());
      syncPaymentFromProvider();
      state = state.copyWith(isLoading: false, pickupConfirmed: true);
      final vehicle = state.selectedVehicle!;
      final payment = ref
          .read(paymentMethodControllerProvider)
          .selectedPaymentMethod;
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
              paymentMethod: payment,
              pickupSpotName: ref
                  .read(getPickupSpotLabelUsecaseProvider)
                  .call(state.selectedPickupSpotIndex),
            ),
          );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not confirm pickup. Try again.',
      );
    }
  }

  void addStop() {
    // TODO: Wire multi-stop waypoints + map reordering when product/API is ready.
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
}
