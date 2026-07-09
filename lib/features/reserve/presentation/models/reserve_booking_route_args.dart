import 'package:go_router/go_router.dart';

class ReserveBookingRouteArgs {
  const ReserveBookingRouteArgs({this.pickupDateIso, this.pickupTimeLabel});

  final String? pickupDateIso;
  final String? pickupTimeLabel;

  static ReserveBookingRouteArgs fromState(GoRouterState state) {
    final extra = state.extra;
    if (extra is ReserveBookingRouteArgs) {
      return extra;
    }
    if (extra is Map) {
      return ReserveBookingRouteArgs(
        pickupDateIso: extra['pickupDateIso'] as String?,
        pickupTimeLabel: extra['pickupTimeLabel'] as String?,
      );
    }
    return const ReserveBookingRouteArgs();
  }
}
