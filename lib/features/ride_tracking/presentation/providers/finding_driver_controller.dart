import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ride_booking/presentation/models/ride_flow_extra.dart';
import '../../../ride_booking/presentation/models/ride_vehicle_option.dart';
import '../../../ride_booking/presentation/models/suggested_location.dart';

/// Presentation-only snapshot for Finding Driver chrome.
/// Authoritative booking phase/driver/fare live in [RideBookingController].
class FindingDriverState {
  const FindingDriverState({
    this.selectedRideType = 'Ride',
    this.pickupLocation = '',
    this.pickupSpotName = '',
    this.destination,
    this.selectedVehicle,
    this.estimatedFare = '',
    this.paymentMethod = '',
    this.isSearching = true,
    this.errorMessage,
  });

  final String selectedRideType;
  final String pickupLocation;
  final String pickupSpotName;
  final SuggestedLocation? destination;
  final RideVehicleOption? selectedVehicle;
  final String estimatedFare;
  final String paymentMethod;
  final bool isSearching;
  final String? errorMessage;

  FindingDriverState copyWith({
    String? selectedRideType,
    String? pickupLocation,
    String? pickupSpotName,
    SuggestedLocation? destination,
    RideVehicleOption? selectedVehicle,
    String? estimatedFare,
    String? paymentMethod,
    bool? isSearching,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FindingDriverState(
      selectedRideType: selectedRideType ?? this.selectedRideType,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupSpotName: pickupSpotName ?? this.pickupSpotName,
      destination: destination ?? this.destination,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FindingDriverController extends Notifier<FindingDriverState> {
  @override
  FindingDriverState build() => const FindingDriverState();

  void clearError() {
    state = state.copyWith(clearError: true);
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
      isSearching: true,
      clearError: true,
    );
  }

  void stopSearching() {
    state = state.copyWith(isSearching: false);
  }
}
