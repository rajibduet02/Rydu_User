import 'package:go_router/go_router.dart';

import '../../../features/home/presentation/screens/schedule_ride_placeholder_screen.dart';
import '../../../features/offers/presentation/screens/offers_screen.dart';
import '../route_names.dart';

/// Home and offers routes.
List<RouteBase> get homeRoutes => [
  GoRoute(
    path: RouteNames.offers,
    pageBuilder: (context, state) =>
        NoTransitionPage<void>(key: state.pageKey, child: const OffersScreen()),
  ),
  GoRoute(
    path: RouteNames.scheduleRide,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const ScheduleRidePlaceholderScreen(),
    ),
  ),
];
