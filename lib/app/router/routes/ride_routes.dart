import 'package:go_router/go_router.dart';

import '../../../features/account/presentation/screens/support_flow_placeholder_screen.dart';
import '../../../features/chat/presentation/screens/chat_screen.dart';
import '../../../features/map/presentation/screens/map_screen.dart';
import '../../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';
import '../../../features/ride_booking/presentation/models/ride_booking_route_args.dart';
import '../../../features/ride_booking/presentation/models/select_vehicle_route_args.dart';
import '../../../features/ride_booking/presentation/screens/confirm_ride_screen.dart';
import '../../../features/ride_booking/presentation/screens/confirm_pickup_screen.dart';
import '../../../features/ride_booking/presentation/screens/ride_booking_screen.dart';
import '../../../features/ride_booking/presentation/screens/ride_selection_screen.dart';
import '../../../features/ride_booking/presentation/screens/search_destination_screen.dart';
import '../../../features/ride_booking/presentation/screens/searching_driver_screen.dart';
import '../../../features/ride_booking/presentation/screens/select_vehicle_screen.dart';
import '../../../features/ride_history/presentation/screens/ride_details_screen.dart';
import '../../../features/ride_history/presentation/screens/ride_history_screen.dart';
import '../../../features/ride_tracking/presentation/screens/driver_found_screen.dart';
import '../../../features/ride_tracking/presentation/screens/finding_driver_screen.dart';
import '../../../features/ride_tracking/presentation/screens/ride_tracking_screen.dart';
import '../route_names.dart';

/// Map, ride booking, tracking, history, chat, notifications, and profile routes.
List<RouteBase> get rideRoutes => [
  GoRoute(path: RouteNames.map, builder: (context, state) => const MapScreen()),
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
    builder: (context, state) => const SearchDestinationScreen(),
  ),
  GoRoute(
    path: RouteNames.selectVehicle,
    builder: (context, state) {
      final args = SelectVehicleRouteArgs.fromState(state);
      return SelectVehicleScreen(routeArgs: args);
    },
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
    builder: (context, state) => const ConfirmRideScreen(),
  ),
  GoRoute(
    path: RouteNames.searchingDriver,
    builder: (context, state) => const SearchingDriverScreen(),
  ),
  GoRoute(
    path: RouteNames.rideTracking,
    builder: (context, state) => const RideTrackingScreen(),
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
    builder: (context, state) => const ProfileScreen(),
  ),
  GoRoute(
    path: RouteNames.editProfile,
    builder: (context, state) => const EditProfileScreen(),
  ),
];
