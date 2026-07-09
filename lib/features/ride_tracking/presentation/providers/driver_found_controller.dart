import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../ride_booking/presentation/models/ride_flow_extra.dart';
import '../../../ride_booking/presentation/models/ride_vehicle_option.dart';
import '../../../ride_booking/presentation/models/suggested_location.dart';
import 'ride_tracking_dependencies.dart';

class DriverFoundState {
  const DriverFoundState({
    this.selectedRideType = 'Ride',
    this.pickupLocation = '35 Road No. 2',
    this.pickupSpotName = 'Waffle Hut Basunhare',
    this.destination,
    this.selectedVehicle,
    this.estimatedFare = 'BDT 155.84',
    this.paymentMethod = 'Cash',
    this.driverName = 'MOHAMMAD MOHIDUL ISLAM',
    this.driverRating = '4.9',
    this.vehicleName = 'CNG',
    this.plateNumber = 'DHM-LA-63-525',
    this.eta = '2 min',
    this.tripStatus = 'Active',
    this.rideId = 'BDT12138',
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

  Future<void> initializeFromExtra(Map<String, dynamic> extra) async {
    final type = RideFlowExtra.stringFrom(extra['selectedType'], 'Ride');
    final pickup = RideFlowExtra.stringFrom(extra['pickupLocation']);
    final spot = RideFlowExtra.stringFrom(
      extra['pickupSpotName'],
      'Waffle Hut Basunhare',
    );
    final destination = RideFlowExtra.destinationFrom(extra['destination']);
    final vehicle = rideVehicleOptionFromExtra(extra['selectedVehicle']);
    final fare = RideFlowExtra.stringFrom(
      extra['estimatedFare'],
      vehicle?.price ?? 'BDT 155.84',
    );
    final payment = RideFlowExtra.stringFrom(extra['paymentMethod'], 'Cash');

    final trip = await ref
        .read(getDriverFoundUsecaseProvider)
        .call(
          vehicleName: vehicle?.name,
          estimatedFare: fare,
          paymentMethod: payment,
        );

    state = state.copyWith(
      selectedRideType: type,
      pickupLocation: pickup,
      pickupSpotName: spot,
      destination: destination,
      selectedVehicle: vehicle,
      estimatedFare: trip.estimatedFare,
      paymentMethod: trip.paymentMethod,
      driverName: trip.driver.name,
      driverRating: trip.driver.rating,
      vehicleName: trip.driver.vehicleName,
      plateNumber: trip.driver.plateNumber,
      eta: trip.driver.eta,
      tripStatus: trip.tripStatus,
      rideId: trip.rideId,
      clearError: true,
    );
  }

  void toggleTripDetails() {
    state = state.copyWith(showTripDetails: !state.showTripDetails);
  }

  Future<void> callDriver() async {
    await ref.read(contactDriverUsecaseProvider).call();
    state = state.copyWith(clearError: true);
  }

  void messageDriver() {
    ref.read(goRouterProvider).push(RouteNames.chat);
  }

  Future<void> shareTripStatus() async {
    await ref.read(shareTripStatusUsecaseProvider).call();
    state = state.copyWith(clearError: true);
  }

  Future<void> cancelRide() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(cancelRideUsecaseProvider).call();
      state = state.copyWith(isLoading: false);
      ref.read(goRouterProvider).go(RouteNames.home);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not cancel ride.',
      );
    }
  }
}
