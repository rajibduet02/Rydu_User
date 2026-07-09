import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../onboarding/presentation/theme/welcome_tokens.dart';
import '../../../onboarding/presentation/widgets/welcome_action_button.dart';
import '../providers/register_controller.dart';
import '../theme/auth_screen_tokens.dart';
import '../widgets/auth_labeled_field.dart';
import '../widgets/auth_prompt_link.dart';

/// Registration screen with full name, email, password, and confirm password.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(registerControllerProvider);
    _nameController = TextEditingController(text: initial.fullName);
    _emailController = TextEditingController(text: initial.email);
    _passwordController = TextEditingController(text: initial.password);
    _confirmPasswordController = TextEditingController(
      text: initial.confirmPassword,
    );
    _nameController.addListener(_syncName);
    _emailController.addListener(_syncEmail);
    _passwordController.addListener(_syncPassword);
    _confirmPasswordController.addListener(_syncConfirm);
  }

  void _syncName() {
    ref
        .read(registerControllerProvider.notifier)
        .setFullName(_nameController.text);
  }

  void _syncEmail() {
    ref
        .read(registerControllerProvider.notifier)
        .setEmail(_emailController.text);
  }

  void _syncPassword() {
    ref
        .read(registerControllerProvider.notifier)
        .setPassword(_passwordController.text);
  }

  void _syncConfirm() {
    ref
        .read(registerControllerProvider.notifier)
        .setConfirmPassword(_confirmPasswordController.text);
  }

  @override
  void dispose() {
    _nameController.removeListener(_syncName);
    _emailController.removeListener(_syncEmail);
    _passwordController.removeListener(_syncPassword);
    _confirmPasswordController.removeListener(_syncConfirm);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToSignIn() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.auth);
    }
  }

  Future<void> _onSignUp() async {
    await ref.read(registerControllerProvider.notifier).signUp();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(registerControllerProvider);
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
            Padding(
              padding: EdgeInsets.only(left: horizontal * 0.15, top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: s.isSubmitting ? null : _goToSignIn,
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
                  4,
                  horizontal,
                  bottomInset + WelcomeTokens.spaceBottom + bottomPad + 24,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create account',
                      style: TextStyle(
                        color: WelcomeTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: WelcomeTokens.titleBottom),
                    Text(
                      'Sign up to start riding with RYD U',
                      style: TextStyle(
                        color: WelcomeTokens.muted,
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthLabeledField(
                      label: 'Full name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
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
                      hint: 'Create a password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),
                    AuthLabeledField(
                      label: 'Confirm password',
                      hint: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (s.canSignUp) _onSignUp();
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
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
                    const SizedBox(height: 24),
                    WelcomeActionButton.primary(
                      label: 'Sign Up',
                      isLoading: s.isSubmitting,
                      onPressed: s.canSignUp ? _onSignUp : null,
                    ),
                    const SizedBox(height: WelcomeTokens.spaceBetweenButtons),
                    AuthPromptLink(
                      prefix: 'Have an account? ',
                      linkLabel: 'Sign In',
                      enabled: !s.isSubmitting,
                      onLinkTap: _goToSignIn,
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
