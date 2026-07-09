import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_dependencies.dart';

class OtpState {
  OtpState({
    required this.phoneRaw,
    required this.phoneDisplay,
    List<String>? otpDigits,
    this.isLoading = false,
    this.errorMessage,
    this.remainingSeconds = 24,
    this.canResend = false,
    this.resendEpoch = 0,
  }) : otpDigits = List<String>.from(otpDigits ?? const ['', '', '', '']) {
    assert(this.otpDigits.length == 4);
  }

  final String phoneRaw;
  final String phoneDisplay;
  final List<String> otpDigits;
  final bool isLoading;
  final String? errorMessage;
  final int remainingSeconds;
  final bool canResend;
  final int resendEpoch;

  String get otpCode => otpDigits.join();

  bool get isOtpComplete =>
      otpDigits.length == 4 && otpDigits.every((d) => d.isNotEmpty);

  OtpState copyWith({
    String? phoneRaw,
    String? phoneDisplay,
    List<String>? otpDigits,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? remainingSeconds,
    bool? canResend,
    int? resendEpoch,
  }) {
    return OtpState(
      phoneRaw: phoneRaw ?? this.phoneRaw,
      phoneDisplay: phoneDisplay ?? this.phoneDisplay,
      otpDigits: otpDigits ?? List<String>.from(this.otpDigits),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      canResend: canResend ?? this.canResend,
      resendEpoch: resendEpoch ?? this.resendEpoch,
    );
  }
}

class OtpController extends Notifier<OtpState> {
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() => _timer?.cancel());
    return OtpState(phoneRaw: '+10000000000', phoneDisplay: '+1 000 000 0000');
  }

  void initialize({String? phoneQuery}) {
    _timer?.cancel();
    final decoded = (phoneQuery != null && phoneQuery.isNotEmpty)
        ? Uri.decodeComponent(phoneQuery)
        : null;
    final raw = decoded ?? '+10000000000';
    final display = decoded ?? '+1 000 000 0000';
    state = OtpState(
      phoneRaw: raw,
      phoneDisplay: display,
      otpDigits: const ['', '', '', ''],
      remainingSeconds: 24,
      canResend: false,
      resendEpoch: state.resendEpoch + 1,
    );
    startResendTimer();
  }

  void updateOtpDigit(int index, String value) {
    if (index < 0 || index > 3) return;
    final sanitized = value.replaceAll(RegExp(r'\D'), '');
    final char = sanitized.isEmpty
        ? ''
        : sanitized.substring(sanitized.length - 1);
    final next = List<String>.from(state.otpDigits);
    next[index] = char;
    state = state.copyWith(otpDigits: next, clearError: true);
  }

  void setOtpCode(String value) {
    final digits = value
        .replaceAll(RegExp(r'\D'), '')
        .split('')
        .take(4)
        .toList();
    while (digits.length < 4) {
      digits.add('');
    }
    state = state.copyWith(otpDigits: digits.sublist(0, 4), clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void startResendTimer() {
    _timer?.cancel();
    state = state.copyWith(remainingSeconds: 24, canResend: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final sec = state.remainingSeconds;
      if (sec <= 1) {
        _timer?.cancel();
        state = state.copyWith(remainingSeconds: 0, canResend: true);
      } else {
        state = state.copyWith(remainingSeconds: sec - 1);
      }
    });
  }

  Future<void> resendOtp() async {
    if (!state.canResend) return;
    await ref.read(sendOtpUsecaseProvider).call(phone: state.phoneRaw);
    state = state.copyWith(
      otpDigits: const ['', '', '', ''],
      clearError: true,
      resendEpoch: state.resendEpoch + 1,
    );
    startResendTimer();
  }

  /// Returns `true` when navigation to home should run.
  Future<bool> verifyOtp() async {
    if (!state.isOtpComplete) {
      state = state.copyWith(errorMessage: 'Enter the 4-digit code.');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // TODO: Firebase / backend verification when configured.
      await ref
          .read(verifyOtpUsecaseProvider)
          .call(phone: state.phoneRaw, code: state.otpCode);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Verification failed. Please try again.',
        isLoading: false,
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final otpControllerProvider = NotifierProvider<OtpController, OtpState>(
  OtpController.new,
);
