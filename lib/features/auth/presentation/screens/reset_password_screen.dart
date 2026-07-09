import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../onboarding/presentation/theme/welcome_tokens.dart';
import '../../../onboarding/presentation/widgets/welcome_action_button.dart';
import '../providers/reset_password_controller.dart';
import '../theme/auth_screen_tokens.dart';
import '../widgets/auth_labeled_field.dart';

/// Set a new password after OTP verification in the forgot-password flow.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(resetPasswordControllerProvider);
    _newPasswordController = TextEditingController(text: initial.newPassword);
    _confirmPasswordController = TextEditingController(
      text: initial.confirmPassword,
    );
    _newPasswordController.addListener(_syncNew);
    _confirmPasswordController.addListener(_syncConfirm);
  }

  void _syncNew() {
    ref
        .read(resetPasswordControllerProvider.notifier)
        .setNewPassword(_newPasswordController.text);
  }

  void _syncConfirm() {
    ref
        .read(resetPasswordControllerProvider.notifier)
        .setConfirmPassword(_confirmPasswordController.text);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_syncNew);
    _confirmPasswordController.removeListener(_syncConfirm);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.auth);
    }
  }

  Future<void> _onSubmit() async {
    await ref
        .read(resetPasswordControllerProvider.notifier)
        .submitNewPassword();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(resetPasswordControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = (w * 0.06).clamp(20.0, 28.0);
    final titleSize = (w * 0.08).clamp(24.0, 30.0);
    final subtitleSize = (w * 0.042).clamp(15.0, 17.0);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: WelcomeTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: horizontal * 0.15, top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: s.isSubmitting ? null : _goBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: WelcomeTokens.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  8,
                  horizontal,
                  8 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create new password',
                      style: TextStyle(
                        color: WelcomeTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: WelcomeTokens.titleBottom),
                    Text(
                      'Choose a strong password for your account.',
                      style: TextStyle(
                        color: WelcomeTokens.muted,
                        fontSize: subtitleSize,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthLabeledField(
                      label: 'New password',
                      hint: 'Enter new password',
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscureNew = !_obscureNew);
                        },
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AuthScreenTokens.muted,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthLabeledField(
                      label: 'Confirm password',
                      hint: 'Re-enter new password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (s.canSubmit) _onSubmit();
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AuthScreenTokens.muted,
                          size: 22,
                        ),
                      ),
                    ),
                    if (s.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        s.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                8,
                horizontal,
                WelcomeTokens.spaceBottom + bottomPad,
              ),
              child: WelcomeActionButton.primary(
                label: 'Update password',
                isLoading: s.isSubmitting,
                onPressed: s.canSubmit ? _onSubmit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
