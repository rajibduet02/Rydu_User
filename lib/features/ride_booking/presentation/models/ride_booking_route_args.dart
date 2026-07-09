import 'package:go_router/go_router.dart';

/// Arguments for [RouteNames.rideBooking], from `extra` or query `selectedType`.
class RideBookingRouteArgs {
  const RideBookingRouteArgs({
    required this.selectedType,
    this.rentalHours,
    this.leaveOption,
    this.rentalVehicle,
    this.price,
    this.paymentMethod,
  });

  final String selectedType;
  final int? rentalHours;
  final String? leaveOption;
  final String? rentalVehicle;
  final double? price;
  final String? paymentMethod;

  static int? _parseHours(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static double? _parsePrice(Object? raw) {
    if (raw == null) return null;
    if (raw is double) return raw;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  static RideBookingRouteArgs fromState(GoRouterState state) {
    final q = state.uri.queryParameters['selectedType'];
    final qh = state.uri.queryParameters['rentalHours'];
    final extra = state.extra;
    if (extra is RideBookingRouteArgs) {
      return extra;
    }
    if (extra is Map) {
      final t = extra['selectedType'] as String? ?? q;
      final rentHours =
          _parseHours(extra['rentalHours']) ??
          (qh != null ? int.tryParse(qh) : null);
      final leave = extra['leaveOption'] as String?;
      final vehicle = extra['rentalVehicle'] as String?;
      final price = _parsePrice(extra['price']);
      final pay = extra['paymentMethod'] as String?;
      return RideBookingRouteArgs(
        selectedType: t ?? 'Ride',
        rentalHours: rentHours,
        leaveOption: leave,
        rentalVehicle: vehicle,
        price: price,
        paymentMethod: pay,
      );
    }
    if (q != null && q.isNotEmpty) {
      return RideBookingRouteArgs(
        selectedType: q,
        rentalHours: qh != null ? int.tryParse(qh) : null,
      );
    }
    return const RideBookingRouteArgs(selectedType: 'Ride');
  }
}
