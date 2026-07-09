import 'package:flutter_riverpod/flutter_riverpod.dart';

class NameInputState {
  const NameInputState({
    this.firstName = '',
    this.lastName = '',
    this.isLoading = false,
    this.errorMessage,
    this.hasInteracted = false,
  });

  final String firstName;
  final String lastName;
  final bool isLoading;
  final String? errorMessage;
  final bool hasInteracted;

  /// Trimmed first name must be at least 2 characters.
  bool get isFirstNameValid => firstName.trim().length >= 2;

  NameInputState copyWith({
    String? firstName,
    String? lastName,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? hasInteracted,
  }) {
    return NameInputState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasInteracted: hasInteracted ?? this.hasInteracted,
    );
  }
}

class NameInputController extends Notifier<NameInputState> {
  @override
  NameInputState build() => const NameInputState();

  void reset() {
    state = const NameInputState();
  }

  void updateFirstName(String value) {
    state = state.copyWith(firstName: value);
    if (state.isFirstNameValid) {
      state = state.copyWith(clearError: true);
    }
  }

  void updateLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Sets [hasInteracted] and [errorMessage] when first name is invalid.
  void validateFirstName() {
    final trimmed = state.firstName.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        hasInteracted: true,
        errorMessage: 'First name is required',
      );
      return;
    }
    if (trimmed.length < 2) {
      state = state.copyWith(
        hasInteracted: true,
        errorMessage: 'First name must be at least 2 characters',
      );
      return;
    }
    state = state.copyWith(hasInteracted: true, clearError: true);
  }

  /// Returns `true` when navigation should proceed.
  Future<bool> submitName() async {
    validateFirstName();
    if (!state.isFirstNameValid) {
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // TODO: Persist display name via API when backend is ready.
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return true;
    } catch (e) {
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

final nameInputControllerProvider =
    NotifierProvider<NameInputController, NameInputState>(
      NameInputController.new,
    );
