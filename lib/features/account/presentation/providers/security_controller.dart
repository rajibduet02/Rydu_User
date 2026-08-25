import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

class SecurityState {
  const SecurityState({
    this.securityStatus = '',
    this.hasThreats = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String securityStatus;
  final bool hasThreats;
  final bool isLoading;
  final String? errorMessage;

  SecurityState copyWith({
    String? securityStatus,
    bool? hasThreats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SecurityState(
      securityStatus: securityStatus ?? this.securityStatus,
      hasThreats: hasThreats ?? this.hasThreats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SecurityController extends Notifier<SecurityState> {
  @override
  SecurityState build() => const SecurityState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> loadSecurityData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(getSecurityDataUsecaseProvider).call();
      state = state.copyWith(
        isLoading: false,
        securityStatus: data.securityStatus,
        hasThreats: data.hasThreats,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load security settings.',
      );
    }
  }

  void openNotifications() {
    ref.read(goRouterProvider).push(RouteNames.notifications);
  }

  void openChangePassword() {
    ref.read(goRouterProvider).push(RouteNames.forgotPassword);
  }

  void openAuthenticatorApp() {
    ref.read(goRouterProvider).push(RouteNames.authenticatorApp);
  }

  void openTwoStepVerification() {
    ref.read(goRouterProvider).push(RouteNames.twoStepVerification);
  }

  void openRecoveryPhone() {
    ref.read(goRouterProvider).push(RouteNames.recoveryPhone);
  }

  void openPrivacyPolicy() {
    ref.read(goRouterProvider).push(RouteNames.privacyPolicy);
  }
}
