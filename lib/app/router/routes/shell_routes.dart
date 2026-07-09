import 'package:go_router/go_router.dart';

import '../../../features/account/presentation/screens/account_screen.dart';
import '../../../features/activity/presentation/screens/activity_screen.dart';
import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/services/presentation/screens/services_screen.dart';
import '../main_shell_screen.dart';
import '../route_names.dart';

/// Bottom navigation shell routes.
RouteBase get shellRoute => StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      MainShellScreen(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RouteNames.home,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RouteNames.services,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const ServicesScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RouteNames.activity,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const ActivityScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: RouteNames.account,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const AccountScreen(),
          ),
        ),
      ],
    ),
  ],
);
