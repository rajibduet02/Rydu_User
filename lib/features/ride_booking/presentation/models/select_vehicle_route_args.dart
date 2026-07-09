import 'package:go_router/go_router.dart';

/// Booking context passed into [RouteNames.selectVehicle].
class SelectVehicleRouteArgs {
  const SelectVehicleRouteArgs({
    required this.selectedRideType,
    required this.pickupAddress,
    this.destinationName,
    this.destinationAddress,
  });

  final String selectedRideType;
  final String pickupAddress;
  final String? destinationName;
  final String? destinationAddress;

  static SelectVehicleRouteArgs? fromState(GoRouterState state) {
    final extra = state.extra;
    if (extra is SelectVehicleRouteArgs) {
      return extra;
    }
    if (extra is Map) {
      return SelectVehicleRouteArgs(
        selectedRideType:
            extra['selectedRideType'] as String? ??
            extra['selectedType'] as String? ??
            'Ride',
        pickupAddress: extra['pickupAddress'] as String? ?? '',
        destinationName: extra['destinationName'] as String?,
        destinationAddress: extra['destinationAddress'] as String?,
      );
    }
    return null;
  }
}
