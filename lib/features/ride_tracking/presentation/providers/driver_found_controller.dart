import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../ride_booking/presentation/models/ride_flow_extra.dart';
import '../../../ride_booking/presentation/models/ride_vehicle_option.dart';
import '../../../ride_booking/presentation/models/suggested_location.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';

class DriverFoundState {
  const DriverFoundState({
    this.selectedRideType = 'Ride',
    this.pickupLocation = '',
    this.pickupSpotName = '',
    this.destination,
    this.selectedVehicle,
    this.estimatedFare = '',
    this.paymentMethod = '',
    this.driverName = '',
    this.driverRating = '',
    this.vehicleName = '',
    this.plateNumber = '',
    this.eta = '',
    this.tripStatus = '',
    this.rideId = '',
    this.isLoading = false,
    this.errorMessage,
    this.showTripDetails = false,
  });

  final String selectedRideType;
  final String pickupLocation;
  final String pickupSpotName;
  final SuggestedLocation? destination;
  final RideVehicleOption? selectedVehicle;
  final String estimatedFare;
  final String paymentMethod;
  final String driverName;
  final String driverRating;
  final String vehicleName;
  final String plateNumber;
  final String eta;
  final String tripStatus;
  final String rideId;
  final bool isLoading;
  final String? errorMessage;
  final bool showTripDetails;

  DriverFoundState copyWith({
    String? selectedRideType,
    String? pickupLocation,
    String? pickupSpotName,
    SuggestedLocation? destination,
    RideVehicleOption? selectedVehicle,
    String? estimatedFare,
    String? paymentMethod,
    String? driverName,
    String? driverRating,
    String? vehicleName,
    String? plateNumber,
    String? eta,
    String? tripStatus,
    String? rideId,
    bool? isLoading,
    String? errorMessage,
    bool? showTripDetails,
    bool clearError = false,
  }) {
    return DriverFoundState(
      selectedRideType: selectedRideType ?? this.selectedRideType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupSpotName: pickupSpotName ?? this.pickupSpotName,
      destination: destination ?? this.destination,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      vehicleName: vehicleName ?? this.vehicleName,
      plateNumber: plateNumber ?? this.plateNumber,
      eta: eta ?? this.eta,
      tripStatus: tripStatus ?? this.tripStatus,
      rideId: rideId ?? this.rideId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      showTripDetails: showTripDetails ?? this.showTripDetails,
    );
  }
}

class DriverFoundController extends Notifier<DriverFoundState> {
  @override
  DriverFoundState build() => const DriverFoundState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void syncFromRideBooking(RideBookingState ride) {
    final driver = ride.assignedDriver;
    final etaMinutes = driver?.etaMinutes;
    final phaseLabel = switch (ride.phase) {
      RidePlanningPhase.driverAccepted => 'Driver assigned',
      RidePlanningPhase.driverEnRoute => 'Driver en route',
      RidePlanningPhase.driverArrived => 'Driver arrived',
      RidePlanningPhase.rideInProgress => 'Trip in progress',
      RidePlanningPhase.completed => 'Completed',
      RidePlanningPhase.cancelled => 'Cancelled',
      _ => ride.bookingStatus ?? 'Active',
    };

    state = state.copyWith(
      selectedRideType: ride.selectedRideType,
      pickupLocation: ride.pickupLocation,
      pickupSpotName: ride.pickupSpotLabel,
      destination: ride.selectedDestination,
      selectedVehicle: ride.selectedVehicle,
      estimatedFare: ride.estimatedFare ?? '',
      paymentMethod: ride.paymentMethod,
      driverName: driver?.name ?? '',
      driverRating: driver?.rating ?? '',
      vehicleName: driver?.vehicleName ?? ride.selectedVehicle?.name ?? '',
      plateNumber: driver?.plateNumber ?? '',
      eta: etaMinutes != null ? '$etaMinutes min' : '',
      tripStatus: phaseLabel,
      rideId: ride.bookingNumber ?? ride.bookingId ?? '',
      clearError: true,
    );
  }

  void initializeFromExtra(Map<String, dynamic> extra) {
    final type = RideFlowExtra.stringFrom(extra['selectedType'], 'Ride');
    final pickup = RideFlowExtra.stringFrom(extra['pickupLocation']);
    final spot = RideFlowExtra.stringFrom(extra['pickupSpotName']);
    final destination = RideFlowExtra.destinationFrom(extra['destination']);
    final vehicle = rideVehicleOptionFromExtra(extra['selectedVehicle']);
    final fare = RideFlowExtra.stringFrom(
      extra['estimatedFare'],
      vehicle?.price ?? '',
    );
    final payment = RideFlowExtra.stringFrom(extra['paymentMethod']);

    state = state.copyWith(
      selectedRideType: type,
      pickupLocation: pickup,
      pickupSpotName: spot,
      destination: destination,
      selectedVehicle: vehicle,
      estimatedFare: fare,
      paymentMethod: payment,
      clearError: true,
    );

    syncFromRideBooking(ref.read(rideBookingControllerProvider));
  }

  void toggleTripDetails() {
    state = state.copyWith(showTripDetails: !state.showTripDetails);
  }

  Future<void> callDriver() async {
    state = state.copyWith(clearError: true);
  }

  void messageDriver() {
    ref.read(goRouterProvider).push(RouteNames.chat);
  }

  Future<void> shareTripStatus() async {
    state = state.copyWith(clearError: true);
  }

  Future<bool> cancelRide({String? reason}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ok = await ref
        .read(rideBookingControllerProvider.notifier)
        .cancelActiveBooking(reason: reason);
    state = state.copyWith(
      isLoading: false,
      errorMessage: ok
          ? null
          : ref.read(rideBookingControllerProvider).errorMessage ??
                'Could not cancel ride.',
    );
    return ok;
  }
}
