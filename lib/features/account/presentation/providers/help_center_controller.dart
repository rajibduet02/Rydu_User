import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';

class HelpCenterState {
  const HelpCenterState({
    this.isLoading = false,
    this.errorMessage,
    this.selectedSupportOption,
    this.snackMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? selectedSupportOption;

  /// Shown once as SnackBar then cleared (calling / email not wired yet).
  final String? snackMessage;

  HelpCenterState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? selectedSupportOption,
    bool clearSelectedSupportOption = false,
    String? snackMessage,
    bool clearSnack = false,
  }) {
    return HelpCenterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedSupportOption: clearSelectedSupportOption
          ? null
          : (selectedSupportOption ?? this.selectedSupportOption),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
    );
  }
}

class HelpCenterController extends Notifier<HelpCenterState> {
  @override
  HelpCenterState build() => const HelpCenterState();

  void reset() {
    state = const HelpCenterState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSnack() {
    state = state.copyWith(clearSnack: true);
  }

  void selectSupportOption(String option) {
    state = state.copyWith(selectedSupportOption: option, clearError: true);
  }

  void _push(String location) {
    ref.read(goRouterProvider).push(location);
  }

  void startLiveChat() {
    selectSupportOption('live-chat');
    _push(RouteNames.liveChat);
  }

  void callSupport() {
    selectSupportOption('call');
    _push(RouteNames.callSupport);
  }

  void emailSupport() {
    selectSupportOption('email');
    _push(RouteNames.emailSupport);
  }

  void openFaqs() {
    selectSupportOption('faq');
    _push(RouteNames.faqs);
  }

  void reportRideIssue() {
    selectSupportOption('ride-issues');
    _push(RouteNames.rideIssues);
  }

  void reportLostItem() {
    selectSupportOption('lost-items');
    _push(RouteNames.lostItems);
  }

  void openSafetyResources() {
    selectSupportOption('safety');
    _push(RouteNames.safetyResources);
  }
}
