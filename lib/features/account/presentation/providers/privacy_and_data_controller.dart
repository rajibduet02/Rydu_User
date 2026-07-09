import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

class PrivacyAndDataState {
  const PrivacyAndDataState({
    this.isLoading = false,
    this.errorMessage,
    this.hasRequestedDataDownload = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool hasRequestedDataDownload;

  PrivacyAndDataState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? hasRequestedDataDownload,
    bool clearError = false,
  }) {
    return PrivacyAndDataState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasRequestedDataDownload:
          hasRequestedDataDownload ?? this.hasRequestedDataDownload,
    );
  }
}

class PrivacyAndDataController extends Notifier<PrivacyAndDataState> {
  @override
  PrivacyAndDataState build() => const PrivacyAndDataState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void openPrivacyCenter() {
    ref.read(goRouterProvider).push(RouteNames.privacyCenter);
  }

  void openCommunicationPreferences() {
    ref.read(goRouterProvider).push(RouteNames.communicationPreferences);
  }

  void openSafetyCheckup() {
    ref.read(goRouterProvider).push(RouteNames.privacySafetyCheckup);
  }

  Future<void> requestDownloadData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(requestDataDownloadUsecaseProvider).call();
      state = state.copyWith(isLoading: false, hasRequestedDataDownload: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not submit data archive request.',
      );
    }
  }
}
