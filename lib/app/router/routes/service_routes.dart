import 'package:go_router/go_router.dart';

import '../../../features/intercity/presentation/models/intercity_booking_route_args.dart';
import '../../../features/intercity/presentation/screens/intercity_booking_screen.dart';
import '../../../features/intercity/presentation/screens/intercity_screen.dart';
import '../../../features/rentals/presentation/models/rentals_booking_route_args.dart';
import '../../../features/rentals/presentation/screens/rental_driver_found_screen.dart';
import '../../../features/rentals/presentation/screens/rental_ride_selection_screen.dart';
import '../../../features/rentals/presentation/screens/rental_time_selection_screen.dart';
import '../../../features/rentals/presentation/screens/rentals_booking_screen.dart';
import '../../../features/rentals/presentation/screens/rentals_screen.dart';
import '../../../features/reserve/presentation/models/reserve_booking_route_args.dart';
import '../../../features/reserve/presentation/screens/reserve_booking_screen.dart';
import '../../../features/reserve/presentation/screens/reserve_screen.dart';
import '../route_names.dart';

/// Reserve, intercity, and rentals service routes.
List<RouteBase> get serviceRoutes => [
  GoRoute(
    path: RouteNames.reserve,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const ReserveScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.reserveBooking,
    pageBuilder: (context, state) {
      final args = ReserveBookingRouteArgs.fromState(state);
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: ReserveBookingScreen(routeArgs: args),
      );
    },
  ),
  GoRoute(
    path: RouteNames.intercity,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const IntercityScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.intercityBooking,
    pageBuilder: (context, state) {
      final args = IntercityBookingRouteArgs.fromState(state);
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: IntercityBookingScreen(routeArgs: args),
      );
    },
  ),
  GoRoute(
    path: RouteNames.rentals,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const RentalsScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.rentalTimeSelection,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const RentalTimeSelectionScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.rentalRideSelection,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const RentalRideSelectionScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.rentalDriverFound,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const RentalDriverFoundScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.rentalsBooking,
    pageBuilder: (context, state) {
      final args = RentalsBookingRouteArgs.fromState(state);
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: RentalsBookingScreen(routeArgs: args),
      );
    },
  ),
];
