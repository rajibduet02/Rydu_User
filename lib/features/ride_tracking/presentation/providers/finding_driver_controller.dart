import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../ride_booking/presentation/models/ride_flow_extra.dart';
import '../../../ride_booking/presentation/models/ride_vehicle_option.dart';
import '../../../ride_booking/presentation/models/suggested_location.dart';
import 'ride_tracking_dependencies.dart';

class FindingDriverState {
  const FindingDriverState({
    this.selectedRideType = 'Ride',
    this.pickupLocation = '35 Road No. 2',
    this.pickupSpotName = 'Waffle Hut Basunhare',
    this.destination,
    this.selectedVehicle,
    this.estimatedFare = 'BDT 155.84',
    this.paymentMethod = 'Cash',
    this.isSearching = false,
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

  Map<String, dynamic> toRouteExtra() {
    final vehicle = selectedVehicle;
    return {
      'selectedType': selectedRideType,
      'pickupLocation': pickupLocation,
      'pickupSpotName': pickupSpotName,
      'destination': RideFlowExtra.destinationMap(destination),
      if (vehicle != null) 'selectedVehicle': vehicle.toExtra(),
      'estimatedFare': estimatedFare,
      'paymentMethod': paymentMethod,
    };
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
  }

  Future<void> startSearching() async {
    state = state.copyWith(isSearching: true, clearError: true);
    await ref.read(startFindingDriverUsecaseProvider).call();
  }

  void stopSearching() {
    state = state.copyWith(isSearching: false);
  }

  void navigateToDriverFound() {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      state = state.copyWith(errorMessage: 'Missing vehicle data.');
      return;
    }
    stopSearching();
    ref
        .read(goRouterProvider)
        .pushReplacement(
          RouteNames.driverFound,
          extra: RideFlowExtra.buildDriverFoundExtra(
            selectedType: state.selectedRideType,
            selectedVehicle: vehicle,
            pickupLocation: state.pickupLocation,
            destination: state.destination,
            estimatedFare: state.estimatedFare,
            paymentMethod: state.paymentMethod,
            pickupSpotName: state.pickupSpotName,
          ),
        );
  }
}
