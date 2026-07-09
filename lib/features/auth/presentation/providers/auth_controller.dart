import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import 'auth_dependencies.dart';

class AuthState {
  const AuthState({
    this.user,
    this.phoneDigits = '',
    this.selectedCountryCode = '+1',
    this.isPhoneSubmitting = false,
    this.isGoogleLoading = false,
    this.isAppleLoading = false,
    this.errorMessage,
  });

  final UserEntity? user;
  final String phoneDigits;
  final String selectedCountryCode;
  final bool isPhoneSubmitting;
  final bool isGoogleLoading;
  final bool isAppleLoading;
  final String? errorMessage;

  bool get isPhoneValid => phoneDigits.length >= 10;

  String get fullPhone => '$selectedCountryCode$phoneDigits';

  AuthState copyWith({
    UserEntity? user,
    bool clearUser = false,
    String? phoneDigits,
    String? selectedCountryCode,
    bool? isPhoneSubmitting,
    bool? isGoogleLoading,
    bool? isAppleLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      phoneDigits: phoneDigits ?? this.phoneDigits,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      isPhoneSubmitting: isPhoneSubmitting ?? this.isPhoneSubmitting,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void setPhoneDigits(String digits) {
    state = state.copyWith(phoneDigits: digits, clearError: true);
  }

  void setCountryCode(String code) {
    state = state.copyWith(selectedCountryCode: code, clearError: true);
  }

  /// Returns `true` when navigation to OTP should proceed.
  Future<bool> continueWithPhone() async {
    if (!state.isPhoneValid) {
      state = state.copyWith(
        errorMessage: 'Enter a valid phone number (at least 10 digits).',
      );
      return false;
    }
    state = state.copyWith(isPhoneSubmitting: true, clearError: true);
    try {
      // TODO: call send OTP / auth API when backend is ready.
      await Future<void>.delayed(const Duration(milliseconds: 650));
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    } finally {
      state = state.copyWith(isPhoneSubmitting: false);
    }
  }

  /// TODO: Wire Firebase Auth + `google_sign_in` when configured.
  Future<void> continueWithGoogle() async {
    state = state.copyWith(isGoogleLoading: true, clearError: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    } finally {
      state = state.copyWith(isGoogleLoading: false);
    }
  }

  /// TODO: Wire Sign in with Apple (`sign_in_with_apple`) when configured.
  Future<void> continueWithApple() async {
    state = state.copyWith(isAppleLoading: true, clearError: true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
    } finally {
      state = state.copyWith(isAppleLoading: false);
    }
  }

  Future<void> signOut() async {
    await ref.read(logoutUsecaseProvider).call();
    state = const AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
