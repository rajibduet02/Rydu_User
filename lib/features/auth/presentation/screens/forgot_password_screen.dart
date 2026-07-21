import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../onboarding/presentation/theme/welcome_tokens.dart';
import '../../../onboarding/presentation/widgets/welcome_action_button.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../providers/auth_dependencies.dart';
import '../widgets/auth_labeled_field.dart';

/// Forgot password — collects email and requests a reset link from the API.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  late final TextEditingController _emailController;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearError);
    _emailController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.auth);
    }
  }

  bool get _isEmailValid => _emailRegex.hasMatch(_emailController.text.trim());

  bool get _canContinue => _isEmailValid && !_isSubmitting;

  Future<void> _onContinue() async {
    final email = _emailController.text.trim();

    if (!_isEmailValid) {
      setState(() {
        _errorMessage = 'Enter a valid email address.';
      });
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(requestPasswordResetUsecaseProvider).call(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check your email for reset password.')),
      );
      context.go(RouteNames.auth);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _goBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: WelcomeTokens.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: WelcomeTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: WelcomeTokens.titleBottom),
                    Text(
                      'Enter your email address and we’ll send reset instructions.',
                      style: TextStyle(
                        color: WelcomeTokens.muted,
                        fontSize: subtitleSize,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthLabeledField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (_canContinue) _onContinue();
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
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
                label: 'Send Reset Link',
                isLoading: _isSubmitting,
                onPressed: _canContinue ? _onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
