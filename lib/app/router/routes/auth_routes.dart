import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/screens/auth_screen.dart';
import '../../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import '../../../features/auth/presentation/screens/name_input_screen.dart';
import '../../../features/auth/presentation/screens/otp_screen.dart';
import '../../../features/auth/presentation/screens/privacy_policy_screen.dart';
import '../../../features/auth/presentation/screens/register_screen.dart';
import '../../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../../features/auth/presentation/screens/terms_of_service_screen.dart';
import '../../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../../features/splash/presentation/screens/splash_screen.dart';
import '../route_names.dart';

/// Splash, onboarding, and authentication routes.
List<RouteBase> get authRoutes => [
  GoRoute(
    path: RouteNames.splash,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: RouteNames.onboarding,
    builder: (context, state) => const OnboardingScreen(),
  ),
  GoRoute(
    path: RouteNames.auth,
    pageBuilder: (context, state) =>
        NoTransitionPage<void>(key: state.pageKey, child: const AuthScreen()),
  ),
  GoRoute(
    path: RouteNames.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: RouteNames.register,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const RegisterScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.otp,
    pageBuilder: (context, state) {
      final phone = state.uri.queryParameters['phone'];
      final flow = state.uri.queryParameters['flow'];
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: OtpScreen(phone: phone, flow: flow),
      );
    },
  ),
  GoRoute(
    path: RouteNames.resetPassword,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const ResetPasswordScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.terms,
    redirect: (context, state) => RouteNames.nameInput,
  ),
  GoRoute(
    path: RouteNames.nameInput,
    pageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const NameInputScreen(),
    ),
  ),
  GoRoute(
    path: RouteNames.welcome,
    redirect: (context, state) => RouteNames.home,
  ),
  GoRoute(
    path: RouteNames.termsOfUse,
    builder: (context, state) =>
        const TermsOfServiceScreen(appBarTitle: 'Terms of Use'),
  ),
  GoRoute(
    path: RouteNames.privacy,
    builder: (context, state) => const PrivacyPolicyScreen(),
  ),
  GoRoute(
    path: RouteNames.privacyNotice,
    builder: (context, state) =>
        const PrivacyPolicyScreen(appBarTitle: 'Privacy Notice'),
  ),
  GoRoute(
    path: RouteNames.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
];
