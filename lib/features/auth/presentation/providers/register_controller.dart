import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/exceptions/auth_exception.dart';
import 'auth_dependencies.dart';

class RegisterState {
  const RegisterState({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isSubmitting;
  final String? errorMessage;

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  bool get isNameValid => fullName.trim().length >= 2;

  bool get isEmailValid => _emailRegex.hasMatch(email.trim());

  bool get isPasswordValid => password.length >= 6;

  bool get passwordsMatch => password.isNotEmpty && password == confirmPassword;

  bool get canSignUp =>
      isNameValid &&
      isEmailValid &&
      isPasswordValid &&
      passwordsMatch &&
      !isSubmitting;

  RegisterState copyWith({
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterState();

  void setFullName(String value) {
    state = state.copyWith(fullName: value, clearError: true);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value, clearError: true);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Returns `true` when navigation after sign-up should proceed.
  Future<bool> signUp() async {
    if (!state.isNameValid) {
      state = state.copyWith(
        errorMessage: 'Enter your full name (at least 2 characters).',
      );
      return false;
    }
    if (!state.isEmailValid) {
      state = state.copyWith(errorMessage: 'Enter a valid email address.');
      return false;
    }
    if (!state.isPasswordValid) {
      state = state.copyWith(
        errorMessage: 'Password must be at least 6 characters.',
      );
      return false;
    }
    if (!state.passwordsMatch) {
      state = state.copyWith(errorMessage: 'Passwords do not match.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(registerUsecaseProvider)
          .call(
            email: state.email.trim(),
            password: state.password,
            displayName: state.fullName.trim(),
          );
      ref.read(authFlashMessageProvider.notifier).state =
          'Account created successfully. Please sign in with your email and password.';
      ref.read(goRouterProvider).go(RouteNames.auth);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterState>(RegisterController.new);
