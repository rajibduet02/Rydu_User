import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'auth_dependencies.dart';

class ResetPasswordState {
  const ResetPasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String newPassword;
  final String confirmPassword;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isNewPasswordValid => newPassword.length >= 6;

  bool get passwordsMatch =>
      newPassword.isNotEmpty && newPassword == confirmPassword;

  bool get canSubmit => isNewPasswordValid && passwordsMatch && !isSubmitting;

  ResetPasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ResetPasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ResetPasswordController extends Notifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  void setNewPassword(String value) {
    state = state.copyWith(newPassword: value, clearError: true);
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Returns `true` when navigation to home should proceed.
  Future<bool> submitNewPassword() async {
    if (!state.isNewPasswordValid) {
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
          .read(resetPasswordUsecaseProvider)
          .call(
            newPassword: state.newPassword,
            confirmPassword: state.confirmPassword,
          );
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

final resetPasswordControllerProvider =
    NotifierProvider<ResetPasswordController, ResetPasswordState>(
      ResetPasswordController.new,
    );
