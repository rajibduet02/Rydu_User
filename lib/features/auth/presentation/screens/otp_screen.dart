import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/otp_controller.dart';
import '../theme/otp_tokens.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/resend_code_timer.dart';

/// OTP verification (React `OTPScreen.tsx` + screenshot).
/// OTP flow mode from query `flow` (e.g. `reset` for forgot-password).
const kOtpFlowReset = 'reset';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.phone, this.flow});

  final String? phone;
  final String? flow;

  bool get isResetFlow => flow == kOtpFlowReset;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(otpControllerProvider.notifier)
          .initialize(phoneQuery: widget.phone);
    });
  }

  Future<void> _onVerify() async {
    final ok = await ref.read(otpControllerProvider.notifier).verifyOtp();
    if (!mounted || !ok) return;
    if (widget.isResetFlow) {
      context.push(RouteNames.resetPassword);
    } else {
      context.go(RouteNames.nameInput);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(otpControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final insets = MediaQuery.viewInsetsOf(context);
    final hPad = (w * 0.06).clamp(20.0, 28.0);
    final titleSize = (w * 0.085).clamp(26.0, 32.0);
    final subtitleSize = (w * 0.045).clamp(16.0, 18.0);

    return Scaffold(
      backgroundColor: OtpTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardOpen = insets.bottom > 0;
            final topSpacing = keyboardOpen
                ? 16.0
                : (constraints.maxHeight * 0.04).clamp(16.0, 40.0);
            final afterSubtitleGap = keyboardOpen
                ? 20.0
                : (constraints.maxHeight * 0.05).clamp(28.0, 40.0);
            final bottomPad = insets.bottom + 24;
            final minContentHeight = constraints.maxHeight;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: hPad,
                right: hPad,
                top: topSpacing,
                bottom: bottomPad,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minContentHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Verify your number',
                      style: TextStyle(
                        color: OtpTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Code sent to ${s.phoneDisplay}',
                      style: TextStyle(
                        color: OtpTokens.muted,
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: afterSubtitleGap),
                    OtpPinInputField(key: ValueKey<int>(s.resendEpoch)),
                    const SizedBox(height: 28),
                    const ResendCodeTimer(),
                    const SizedBox(height: 24),
                    if (s.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          s.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(bottom: keyboardOpen ? 16 : 0),
                      child: _OtpVerifyButton(
                        enabled: s.isOtpComplete && !s.isLoading,
                        isLoading: s.isLoading,
                        onPressed: _onVerify,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OtpVerifyButton extends StatelessWidget {
  const _OtpVerifyButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.04).clamp(15.0, 17.0);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled && !isLoading ? onPressed : null,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [OtpTokens.accent, OtpTokens.accentEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: OtpTokens.accent.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: OtpTokens.white,
                        ),
                      )
                    : Text(
                        'Verify',
                        style: TextStyle(
                          color: OtpTokens.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
