import 'package:go_router/go_router.dart';

class IntercityBookingRouteArgs {
  const IntercityBookingRouteArgs({
    this.destinationId,
    this.cityName,
    this.startingPrice,
  });

  final String? destinationId;
  final String? cityName;
  final String? startingPrice;

  bool get hasDestination =>
      (destinationId?.isNotEmpty ?? false) || (cityName?.isNotEmpty ?? false);

  static IntercityBookingRouteArgs fromState(GoRouterState state) {
    final extra = state.extra;
    if (extra is IntercityBookingRouteArgs) {
      return extra;
    }
    if (extra is Map) {
      return IntercityBookingRouteArgs(
        destinationId: extra['destinationId'] as String?,
        cityName: extra['cityName'] as String?,
        startingPrice: extra['startingPrice'] as String?,
      );
    }
    return const IntercityBookingRouteArgs();
  }
}
