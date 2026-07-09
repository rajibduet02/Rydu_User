import 'package:go_router/go_router.dart';

class RentalsBookingRouteArgs {
  const RentalsBookingRouteArgs({this.packageId});

  final String? packageId;

  static RentalsBookingRouteArgs fromState(GoRouterState state) {
    final extra = state.extra;
    if (extra is RentalsBookingRouteArgs) {
      return extra;
    }
    if (extra is Map) {
      return RentalsBookingRouteArgs(packageId: extra['packageId'] as String?);
    }
    return const RentalsBookingRouteArgs();
  }
}
