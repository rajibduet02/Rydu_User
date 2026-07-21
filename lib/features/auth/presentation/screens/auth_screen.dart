import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../onboarding/presentation/theme/welcome_tokens.dart';
import '../../../onboarding/presentation/widgets/welcome_action_button.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../providers/auth_dependencies.dart';
import '../providers/auth_session_provider.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../theme/auth_screen_tokens.dart';
import '../widgets/auth_labeled_field.dart';
import '../widgets/auth_prompt_link.dart';

/// Sign-in screen (`/auth`) — layout aligned with [WelcomeScreen].
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final flash = ref.read(authFlashMessageProvider);
      if (flash != null) {
        ref.read(authFlashMessageProvider.notifier).state = null;
        setState(() {
          _successMessage = flash;
          _errorMessage = null;
        });
      }
    });
  }

  void _clearError() {
    if (_errorMessage != null || _successMessage != null) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  bool get _isEmailValid => _emailRegex.hasMatch(_emailController.text.trim());

  bool get _isPasswordValid => _passwordController.text.length >= 6;

  bool get _canSignIn => _isEmailValid && _isPasswordValid && !_isSubmitting;

  @override
  void dispose() {
    _emailController.removeListener(_clearError);
    _passwordController.removeListener(_clearError);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    final email = _emailController.text.trim();

    if (!_isEmailValid) {
      setState(() {
        _errorMessage = 'Enter a valid email address.';
      });
      return;
    }
    if (!_isPasswordValid) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final user = await ref
          .read(loginUsecaseProvider)
          .call(email: email, password: _passwordController.text);
      if (!mounted) return;
      ref.read(authSessionProvider.notifier).markAuthenticated(user);
      try {
        await ref
            .read(rideBookingControllerProvider.notifier)
            .restoreActiveBooking(navigate: false);
      } catch (_) {}
      if (!mounted) return;
      ref.read(goRouterProvider).go(RouteNames.home);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = (w * 0.06).clamp(20.0, 28.0);
    final titleSize = (w * 0.09).clamp(28.0, 34.0);
    final subtitleSize = (w * 0.045).clamp(16.0, 18.0);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: WelcomeTokens.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  16,
                  horizontal,
                  bottomInset + WelcomeTokens.spaceBottom + bottomPad + 24,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome to RYD U',
                      style: TextStyle(
                        color: WelcomeTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: WelcomeTokens.titleBottom),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        color: WelcomeTokens.muted,
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthLabeledField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AuthLabeledField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (_canSignIn) _onSignIn();
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AuthScreenTokens.muted,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AuthPromptLink(
                        prefix: '',
                        linkLabel: 'Forgot password?',
                        textAlign: TextAlign.right,
                        enabled: !_isSubmitting,
                        onLinkTap: () =>
                            context.push(RouteNames.forgotPassword),
                      ),
                    ),
                    if (_successMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _successMessage!,
                        style: const TextStyle(
                          color: Color(0xFF4ADE80),
                          fontSize: 13,
                        ),
                      ),
                    ],
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
                    const SizedBox(height: 32),
                    WelcomeActionButton.primary(
                      label: 'Sign in',
                      isLoading: _isSubmitting,
                      onPressed: _canSignIn ? _onSignIn : null,
                    ),
                    const SizedBox(height: WelcomeTokens.spaceBetweenButtons),
                    AuthPromptLink(
                      prefix: "Don't have an account? ",
                      linkLabel: 'Sign Up',
                      enabled: !_isSubmitting,
                      onLinkTap: () => context.push(RouteNames.register),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
