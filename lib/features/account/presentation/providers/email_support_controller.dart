import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

const kEmailSupportCategories = <String>[
  'Ride Issue',
  'Payment Issue',
  'Account Issue',
  'Safety Concern',
  'Lost Item',
  'Other',
];

class EmailSupportState {
  const EmailSupportState({
    this.subject = '',
    this.selectedCategory = 'Ride Issue',
    this.message = '',
    this.attachmentPath,
    this.isFormValid = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.snackMessage,
    this.submitSucceeded = false,
  });

  final String subject;
  final String selectedCategory;
  final String message;
  final String? attachmentPath;
  final bool isFormValid;
  final bool isSubmitting;
  final String? errorMessage;
  final String? snackMessage;
  final bool submitSucceeded;

  EmailSupportState copyWith({
    String? subject,
    String? selectedCategory,
    String? message,
    String? attachmentPath,
    bool clearAttachment = false,
    bool? isFormValid,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? snackMessage,
    bool clearSnack = false,
    bool? submitSucceeded,
    bool clearSubmitSucceeded = false,
  }) {
    return EmailSupportState(
      subject: subject ?? this.subject,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      message: message ?? this.message,
      attachmentPath: clearAttachment
          ? null
          : (attachmentPath ?? this.attachmentPath),
      isFormValid: isFormValid ?? this.isFormValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
      submitSucceeded: clearSubmitSucceeded
          ? false
          : (submitSucceeded ?? this.submitSucceeded),
    );
  }
}

class EmailSupportController extends Notifier<EmailSupportState> {
  @override
  EmailSupportState build() => const EmailSupportState();

  static bool _computeValid(String subject, String message) {
    return subject.trim().isNotEmpty && message.trim().length >= 10;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSnack() {
    state = state.copyWith(clearSnack: true);
  }

  void clearSubmitSucceeded() {
    state = state.copyWith(clearSubmitSucceeded: true);
  }

  void updateSubject(String value) {
    state = state.copyWith(
      subject: value,
      isFormValid: _computeValid(value, state.message),
      clearError: true,
    );
  }

  void updateCategory(String value) {
    state = state.copyWith(selectedCategory: value, clearError: true);
  }

  void updateMessage(String value) {
    state = state.copyWith(
      message: value,
      isFormValid: _computeValid(state.subject, value),
      clearError: true,
    );
  }

  void validateForm() {
    final valid = _computeValid(state.subject, state.message);
    state = state.copyWith(
      isFormValid: valid,
      errorMessage: valid
          ? null
          : 'Subject is required and message must be at least 10 characters.',
      clearError: valid,
    );
  }

  void pickAttachment() {
    state = state.copyWith(
      attachmentPath: 'demo://email-attachment',
      snackMessage: 'File picker coming soon. (TODO: file_picker)',
      clearError: true,
    );
  }

  void removeAttachment() {
    state = state.copyWith(clearAttachment: true, clearError: true);
  }

  Future<void> submitRequest() async {
    validateForm();
    if (!state.isFormValid || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await ref
          .read(submitEmailSupportUsecaseProvider)
          .call(
            subject: state.subject.trim(),
            category: state.selectedCategory,
            message: state.message.trim(),
            attachmentPath: state.attachmentPath,
          );
      state = state.copyWith(
        isSubmitting: false,
        snackMessage: 'Support request submitted',
        submitSucceeded: true,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not submit request. Please try again.',
      );
    }
  }

  void navigateAfterSuccess() {
    if (!state.submitSucceeded) return;
    state = state.copyWith(clearSubmitSucceeded: true);
    ref.read(goRouterProvider).go(RouteNames.helpCenter);
  }
}
