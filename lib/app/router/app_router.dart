import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_session_provider.dart';
import 'route_guards.dart';
import 'route_names.dart';
import 'routes/account_routes.dart';
import 'routes/auth_routes.dart';
import 'routes/home_routes.dart';
import 'routes/payment_routes.dart';
import 'routes/ride_routes.dart';
import 'routes/service_routes.dart';
import 'routes/shell_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) =>
        RouteGuards.redirect(ref.read(authSessionProvider), state),
    routes: [
      ...authRoutes,
      shellRoute,
      ...homeRoutes,
      ...serviceRoutes,
      ...accountRoutes,
      ...rideRoutes,
      ...paymentRoutes,
    ],
  );

  ref.listen(authSessionProvider, (_, _) {
    router.refresh();
  });

  ref.onDispose(router.dispose);
  return router;
});
