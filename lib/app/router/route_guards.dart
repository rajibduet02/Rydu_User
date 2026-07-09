import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/state/auth_session_state.dart';
import 'route_names.dart';

/// Route access rules based on [AuthSessionState].
abstract final class RouteGuards {
  /// Routes accessible without authentication.
  static const publicPaths = <String>{
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.auth,
    RouteNames.login,
    RouteNames.register,
    RouteNames.otp,
    RouteNames.forgotPassword,
    RouteNames.resetPassword,
    RouteNames.nameInput,
    RouteNames.terms,
    RouteNames.termsOfUse,
    RouteNames.privacy,
    RouteNames.privacyNotice,
    RouteNames.privacyPolicy,
  };

  /// Auth screens redirected away from when already signed in.
  static const guestOnlyPaths = <String>{
    RouteNames.auth,
    RouteNames.login,
    RouteNames.register,
  };

  static String? redirect(AuthSessionState session, GoRouterState state) {
    return redirectForLocation(session, state.matchedLocation);
  }

  /// Testable redirect based on matched location only.
  static String? redirectForLocation(
    AuthSessionState session,
    String location,
  ) {
    if (session.isLoading) {
      if (location == RouteNames.splash || location == RouteNames.auth) {
        return null;
      }
      return RouteNames.splash;
    }

    if (session.isAuthenticated) {
      if (guestOnlyPaths.contains(location)) {
        return RouteNames.home;
      }
      return null;
    }

    if (publicPaths.contains(location)) {
      return null;
    }

    return RouteNames.auth;
  }
}
