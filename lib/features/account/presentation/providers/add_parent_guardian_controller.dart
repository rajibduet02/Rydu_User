import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

class AddParentGuardianState {
  const AddParentGuardianState({
    this.name = '',
    this.countryCode = '+880',
    this.phoneNumber = '',
    this.isFormValid = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String name;
  final String countryCode;
  final String phoneNumber;
  final bool isFormValid;
  final bool isLoading;
  final String? errorMessage;

  AddParentGuardianState copyWith({
    String? name,
    String? countryCode,
    String? phoneNumber,
    bool? isFormValid,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddParentGuardianState(
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AddParentGuardianController extends Notifier<AddParentGuardianState> {
  @override
  AddParentGuardianState build() => const AddParentGuardianState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void updateName(String value) {
    state = state.copyWith(name: value, clearError: true);
    validateForm();
  }

  void updatePhoneNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    state = state.copyWith(phoneNumber: digits, clearError: true);
    validateForm();
  }

  void chooseFromContacts() {
    state = state.copyWith(clearError: true);
  }

  bool validateForm({bool setError = false}) {
    final nameOk = state.name.trim().length >= 2;
    final phoneOk = _isValidBangladeshPhone(state.phoneNumber);

    String? error;
    if (setError) {
      if (!nameOk) {
        error = 'Enter a valid name (at least 2 characters).';
      } else if (!phoneOk) {
        error = 'Enter a valid Bangladesh phone number.';
      }
    }

    final valid = nameOk && phoneOk;
    state = state.copyWith(
      isFormValid: valid,
      errorMessage: error,
      clearError: error == null,
    );
    return valid;
  }

  Future<bool> sendGuardianInvite() async {
    if (!validateForm(setError: true)) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(sendGuardianInviteUsecaseProvider)
          .call(
            name: state.name.trim(),
            countryCode: state.countryCode,
            phoneNumber: state.phoneNumber,
          );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not send invite. Try again.',
      );
      return false;
    }
  }

  void navigateAfterSuccess() {
    ref.read(goRouterProvider).go(RouteNames.family);
  }

  static bool _isValidBangladeshPhone(String digits) {
    if (digits.length < 10 || digits.length > 11) return false;
    if (digits.startsWith('01')) return digits.length == 11;
    return digits.length == 10;
  }
}
