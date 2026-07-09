import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'payment_dependencies.dart';

class AddCardState {
  const AddCardState({
    this.cardNumber = '',
    this.expiryDate = '',
    this.cvv = '',
    this.cardholderName = '',
    this.saveCard = true,
    this.isFormValid = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardholderName;
  final bool saveCard;
  final bool isFormValid;
  final bool isLoading;
  final String? errorMessage;

  AddCardState copyWith({
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? cardholderName,
    bool? saveCard,
    bool? isFormValid,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddCardState(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardholderName: cardholderName ?? this.cardholderName,
      saveCard: saveCard ?? this.saveCard,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AddCardController extends AutoDisposeNotifier<AddCardState> {
  @override
  AddCardState build() => const AddCardState();

  static String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  static String _formatCardNumberDigits(String digits) {
    final b = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) b.write(' ');
      b.write(digits[i]);
    }
    return b.toString();
  }

  static String _formatExpiryDigits(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 2) return digits;
    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }

  static bool _validExpiry(String formatted) {
    if (formatted.length != 5) return false;
    final parts = formatted.split('/');
    if (parts.length != 2) return false;
    final m = int.tryParse(parts[0]);
    final y = int.tryParse(parts[1]);
    if (m == null || y == null) return false;
    if (m < 1 || m > 12) return false;
    if (parts[1].length != 2) return false;
    return true;
  }

  bool _computeValid(AddCardState s) {
    final digits = _digitsOnly(s.cardNumber);
    if (digits.length != 16) return false;
    if (!_validExpiry(s.expiryDate)) return false;
    if (s.cvv.length < 3 || s.cvv.length > 4) return false;
    if (s.cardholderName.trim().isEmpty) return false;
    return true;
  }

  void validateForm() {
    final v = _computeValid(state);
    if (v != state.isFormValid) {
      state = state.copyWith(isFormValid: v, clearError: true);
    }
  }

  void updateCardNumber(String value) {
    var d = _digitsOnly(value);
    if (d.length > 16) d = d.substring(0, 16);
    final formatted = _formatCardNumberDigits(d);
    state = state.copyWith(cardNumber: formatted, clearError: true);
    validateForm();
  }

  void updateExpiryDate(String value) {
    var d = _digitsOnly(value);
    if (d.length > 4) d = d.substring(0, 4);
    final formatted = _formatExpiryDigits(d);
    state = state.copyWith(expiryDate: formatted, clearError: true);
    validateForm();
  }

  void updateCvv(String value) {
    var d = _digitsOnly(value);
    if (d.length > 4) d = d.substring(0, 4);
    state = state.copyWith(cvv: d, clearError: true);
    validateForm();
  }

  void updateCardholderName(String value) {
    state = state.copyWith(
      cardholderName: value.toUpperCase(),
      clearError: true,
    );
    validateForm();
  }

  void toggleSaveCard(bool value) {
    state = state.copyWith(saveCard: value, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> addCard() async {
    if (!state.isFormValid || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(addCardUsecaseProvider)
          .call(
            cardNumber: state.cardNumber,
            expiry: state.expiryDate,
            cvv: state.cvv,
            cardholderName: state.cardholderName,
          );
      state = state.copyWith(isLoading: false);
      final router = ref.read(goRouterProvider);
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(RouteNames.rentalRideSelection);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not add card. Try again.',
      );
    }
  }
}
