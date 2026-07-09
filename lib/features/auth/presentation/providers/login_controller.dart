import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'auth_dependencies.dart';

class LoginState {
  const LoginState({
    this.phoneDigits = '',
    this.password = '',
    this.selectedCountryCode = '+880',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String phoneDigits;
  final String password;
  final String selectedCountryCode;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isPhoneValid => phoneDigits.length >= 10;

  bool get isPasswordValid => password.length >= 6;

  bool get canSignIn => isPhoneValid && isPasswordValid && !isSubmitting;

  String get fullPhone => '$selectedCountryCode$phoneDigits';

  LoginState copyWith({
    String? phoneDigits,
    String? password,
    String? selectedCountryCode,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      phoneDigits: phoneDigits ?? this.phoneDigits,
      password: password ?? this.password,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setPhoneDigits(String digits) {
    state = state.copyWith(phoneDigits: digits, clearError: true);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  void setCountryCode(String code) {
    state = state.copyWith(selectedCountryCode: code, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Returns `true` when navigation after sign-in should proceed.
  Future<bool> signIn() async {
    if (!state.isPhoneValid) {
      state = state.copyWith(
        errorMessage: 'Enter a valid phone number (at least 10 digits).',
      );
      return false;
    }
    if (!state.isPasswordValid) {
      state = state.copyWith(
        errorMessage: 'Password must be at least 6 characters.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(signInWithPhoneUsecaseProvider)
          .call(fullPhone: state.fullPhone, password: state.password);
      ref.read(goRouterProvider).go(RouteNames.home);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
