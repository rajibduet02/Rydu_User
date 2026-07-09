import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

class InviteTeenState {
  const InviteTeenState({
    this.name = '',
    this.countryCode = '+880',
    this.phoneNumber = '',
    this.dateOfBirth,
    this.age,
    this.isFormValid = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String name;
  final String countryCode;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final int? age;
  final bool isFormValid;
  final bool isLoading;
  final String? errorMessage;

  InviteTeenState copyWith({
    String? name,
    String? countryCode,
    String? phoneNumber,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    int? age,
    bool clearAge = false,
    bool? isFormValid,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InviteTeenState(
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      age: clearAge ? null : (age ?? this.age),
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class InviteTeenController extends Notifier<InviteTeenState> {
  @override
  InviteTeenState build() => const InviteTeenState();

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

  void selectDateOfBirth(DateTime value) {
    final age = _calculateAge(value, DateTime.now());
    state = state.copyWith(dateOfBirth: value, age: age, clearError: true);
    validateForm();
  }

  void chooseFromContacts() {
    state = state.copyWith(clearError: true);
  }

  bool validateForm({bool setError = false}) {
    final trimmedName = state.name.trim();
    final nameOk = trimmedName.length >= 2;
    final phoneOk = _isValidBangladeshPhone(state.phoneNumber);
    final dob = state.dateOfBirth;
    final ageOk = dob != null && _isValidTeenAge(dob);

    String? error;
    if (setError) {
      if (!nameOk) {
        error = 'Enter a valid name (at least 2 characters).';
      } else if (!phoneOk) {
        error = 'Enter a valid Bangladesh phone number.';
      } else if (dob == null) {
        error = 'Select date of birth.';
      } else if (!ageOk) {
        error = "Teen's age must be 13–17 years old.";
      }
    }

    final valid = nameOk && phoneOk && ageOk;
    state = state.copyWith(
      isFormValid: valid,
      errorMessage: error,
      clearError: error == null,
    );
    return valid;
  }

  Future<bool> sendInvite() async {
    if (!validateForm(setError: true)) return false;
    final dob = state.dateOfBirth;
    if (dob == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(sendTeenInviteUsecaseProvider)
          .call(
            name: state.name.trim(),
            countryCode: state.countryCode,
            phoneNumber: state.phoneNumber,
            dateOfBirth: dob,
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
    final router = ref.read(goRouterProvider);
    if (router.canPop()) {
      router.pop();
    }
    router.go(RouteNames.family);
  }

  static int _calculateAge(DateTime birth, DateTime today) {
    var age = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age;
  }

  static bool _isValidTeenAge(DateTime dob) {
    final age = _calculateAge(dob, DateTime.now());
    return age >= 13 && age <= 17;
  }

  static bool _isValidBangladeshPhone(String digits) {
    if (digits.length < 10 || digits.length > 11) return false;
    if (digits.startsWith('01')) {
      return digits.length == 11;
    }
    return digits.length == 10;
  }
}
