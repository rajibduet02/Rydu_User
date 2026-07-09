import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'welcome_interaction_provider.dart';

enum WelcomeSubmitKind { none, help, skip }

class WelcomeState {
  const WelcomeState({
    this.selectedOffer,
    this.submitKind = WelcomeSubmitKind.none,
    this.errorMessage,
  });

  /// Selected promo label, e.g. `"25% OFF"`, or `null` if none chosen yet.
  final String? selectedOffer;
  final WelcomeSubmitKind submitKind;
  final String? errorMessage;

  bool get isLoading => submitKind != WelcomeSubmitKind.none;

  WelcomeState copyWith({
    String? selectedOffer,
    bool clearSelectedOffer = false,
    WelcomeSubmitKind? submitKind,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WelcomeState(
      selectedOffer: clearSelectedOffer
          ? null
          : (selectedOffer ?? this.selectedOffer),
      submitKind: submitKind ?? this.submitKind,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class WelcomeController extends Notifier<WelcomeState> {
  @override
  WelcomeState build() => const WelcomeState();

  void reset() {
    state = const WelcomeState();
  }

  void selectOffer(String offer) {
    state = state.copyWith(selectedOffer: offer, clearError: true);
  }

  /// Clears errors before the UI navigates to the offers hub.
  void openOffers() {
    state = state.copyWith(clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Returns `true` when the UI should navigate to first-ride help / booking.
  Future<bool> startFirstRideHelp() async {
    state = state.copyWith(
      submitKind: WelcomeSubmitKind.help,
      clearError: true,
    );
    try {
      await ref.read(welcomeInteractionProvider).recordChoice(wantsHelp: true);
      // TODO: Sync first-ride help preference with backend when API is ready.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return true;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Something went wrong. Please try again.',
        submitKind: WelcomeSubmitKind.none,
      );
      return false;
    } finally {
      state = state.copyWith(submitKind: WelcomeSubmitKind.none);
    }
  }

  /// Returns `true` when the UI should navigate home.
  Future<bool> skipFirstRideHelp() async {
    state = state.copyWith(
      submitKind: WelcomeSubmitKind.skip,
      clearError: true,
    );
    try {
      await ref.read(welcomeInteractionProvider).recordChoice(wantsHelp: false);
      // TODO: Sync skip preference with backend when API is ready.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return true;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Something went wrong. Please try again.',
        submitKind: WelcomeSubmitKind.none,
      );
      return false;
    } finally {
      state = state.copyWith(submitKind: WelcomeSubmitKind.none);
    }
  }
}

final welcomeControllerProvider =
    NotifierProvider<WelcomeController, WelcomeState>(WelcomeController.new);
