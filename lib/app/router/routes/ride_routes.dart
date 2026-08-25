import 'package:go_router/go_router.dart';

import '../../../features/account/presentation/screens/support_flow_placeholder_screen.dart';
import '../../../features/chat/presentation/screens/chat_screen.dart';
import '../../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../../features/ride_booking/presentation/screens/confirm_pickup_screen.dart';
import '../../../features/ride_booking/presentation/screens/ride_booking_screen.dart';
import '../../../features/ride_booking/presentation/screens/ride_selection_screen.dart';
import '../../../features/ride_booking/presentation/models/ride_booking_route_args.dart';
import '../../../features/ride_history/presentation/screens/ride_details_screen.dart';
import '../../../features/ride_history/presentation/screens/ride_history_screen.dart';
import '../../../features/ride_tracking/presentation/screens/driver_found_screen.dart';
import '../../../features/ride_tracking/presentation/screens/finding_driver_screen.dart';
import '../route_names.dart';

/// Active passenger ride-booking routes.
///
/// Retained (non-primary) routes are isolated from the live
/// Plan Ride → Selection → Finding Driver → Active Ride chain:
/// - `/map` → redirects to [RouteNames.rideBooking] (legacy map stub)
/// - `/search-destination`, `/select-vehicle`, `/confirm-ride`,
///   `/searching-driver`, `/ride-tracking` → redirect to primary flow
/// Nearby drivers markers: intentionally deferred — datasource exists but
/// pre-booking UI does not require driver coordinates from GET /drivers/nearby.
List<RouteBase> get rideRoutes => [
  GoRoute(
    path: RouteNames.map,
    redirect: (context, state) => RouteNames.rideBooking,
  ),
  GoRoute(
    path: RouteNames.rideBooking,
    pageBuilder: (context, state) {
      final args = RideBookingRouteArgs.fromState(state);
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: RideBookingScreen(routeArgs: args),
      );
    },
  ),
  GoRoute(
    path: RouteNames.rideSelection,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const RideSelectionScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.confirmPickup,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const ConfirmPickupScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.findingDriver,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const FindingDriverScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.driverFound,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const DriverFoundScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.searchDestination,
    redirect: (context, state) => RouteNames.rideBooking,
  ),
  GoRoute(
    path: RouteNames.selectVehicle,
    redirect: (context, state) => RouteNames.rideSelection,
  ),
  GoRoute(
    path: RouteNames.citySearch,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'City search'),
  ),
  GoRoute(
    path: RouteNames.setLocationMap,
    builder: (context, state) =>
        const SupportFlowPlaceholderScreen(title: 'Set location on map'),
  ),
  GoRoute(
    path: RouteNames.confirmRide,
    redirect: (context, state) => RouteNames.rideSelection,
  ),
  GoRoute(
    path: RouteNames.searchingDriver,
    redirect: (context, state) => RouteNames.findingDriver,
  ),
  GoRoute(
    path: RouteNames.rideTracking,
    redirect: (context, state) => RouteNames.driverFound,
  ),
  GoRoute(
    path: RouteNames.rideHistory,
    builder: (context, state) => const RideHistoryScreen(),
  ),
  GoRoute(
    path: RouteNames.rideDetails,
    builder: (context, state) {
      final rideId = state.uri.queryParameters['rideId'];
      return RideDetailsScreen(rideId: rideId);
    },
  ),
  GoRoute(
    path: RouteNames.chat,
    builder: (context, state) => const ChatScreen(),
  ),
  GoRoute(
    path: RouteNames.notifications,
    builder: (context, state) => const NotificationsScreen(),
  ),
  GoRoute(
    path: RouteNames.profile,
    redirect: (context, state) => RouteNames.profileDetails,
  ),
];
