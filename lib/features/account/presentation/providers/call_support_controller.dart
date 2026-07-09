import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

class CallSupportState {
  const CallSupportState({
    this.supportPhoneNumber = '',
    this.isAvailable = true,
    this.isCalling = false,
    this.errorMessage,
    this.snackMessage,
  });

  final String supportPhoneNumber;
  final bool isAvailable;
  final bool isCalling;
  final String? errorMessage;
  final String? snackMessage;

  CallSupportState copyWith({
    String? supportPhoneNumber,
    bool? isAvailable,
    bool? isCalling,
    String? errorMessage,
    bool clearError = false,
    String? snackMessage,
    bool clearSnack = false,
  }) {
    return CallSupportState(
      supportPhoneNumber: supportPhoneNumber ?? this.supportPhoneNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      isCalling: isCalling ?? this.isCalling,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
    );
  }
}

class CallSupportController extends Notifier<CallSupportState> {
  @override
  CallSupportState build() {
    Future.microtask(loadSupportInfo);
    return const CallSupportState();
  }

  Future<void> loadSupportInfo() async {
    try {
      final info = await ref.read(getCallSupportInfoUsecaseProvider).call();
      state = state.copyWith(
        supportPhoneNumber: info.supportPhoneNumber,
        isAvailable: info.isAvailable,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Could not load support info.');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSnack() {
    state = state.copyWith(clearSnack: true);
  }

  Future<void> callNow() async {
    if (state.isCalling) return;
    state = state.copyWith(isCalling: true, clearError: true);
    try {
      await ref.read(initiateSupportCallUsecaseProvider).call();
      state = state.copyWith(
        isCalling: false,
        snackMessage: 'Calling support...',
      );
    } catch (_) {
      state = state.copyWith(
        isCalling: false,
        errorMessage: 'Could not start call.',
      );
    }
  }

  void requestCallback() {
    ref.read(goRouterProvider).push(RouteNames.requestCallback);
  }
}
