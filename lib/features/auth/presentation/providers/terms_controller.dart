import 'package:flutter_riverpod/flutter_riverpod.dart';

class TermsState {
  const TermsState({
    this.isAgreed = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isAgreed;
  final bool isLoading;
  final String? errorMessage;

  TermsState copyWith({
    bool? isAgreed,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TermsState(
      isAgreed: isAgreed ?? this.isAgreed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TermsController extends Notifier<TermsState> {
  @override
  TermsState build() => const TermsState();

  void reset() {
    state = const TermsState();
  }

  void toggleAgreement() {
    state = state.copyWith(isAgreed: !state.isAgreed, clearError: true);
  }

  void setAgreement(bool value) {
    state = state.copyWith(isAgreed: value, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Returns `true` when navigation should proceed.
  Future<bool> acceptTerms() async {
    if (!state.isAgreed) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // TODO: POST acceptance to backend when API is ready.
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return true;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Something went wrong. Please try again.',
        isLoading: false,
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final termsControllerProvider = NotifierProvider<TermsController, TermsState>(
  TermsController.new,
);
