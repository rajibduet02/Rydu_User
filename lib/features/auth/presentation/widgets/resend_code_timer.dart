import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/otp_controller.dart';
import '../theme/otp_tokens.dart';

/// “Resend code in 24s” with accent countdown, or tappable “Resend code”.
class ResendCodeTimer extends ConsumerWidget {
  const ResendCodeTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(otpControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final baseSize = (w * 0.04).clamp(14.0, 16.0);

    if (s.remainingSeconds > 0) {
      return Text.rich(
        TextSpan(
          style: TextStyle(
            color: OtpTokens.muted,
            fontSize: baseSize,
            height: 1.35,
          ),
          children: [
            const TextSpan(text: 'Resend code in '),
            TextSpan(
              text: '${s.remainingSeconds}s',
              style: TextStyle(
                color: OtpTokens.accent,
                fontSize: baseSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    return GestureDetector(
      onTap: s.canResend
          ? () => ref.read(otpControllerProvider.notifier).resendOtp()
          : null,
      child: Text(
        'Resend code',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: s.canResend ? OtpTokens.accent : OtpTokens.muted,
          fontSize: baseSize,
          fontWeight: FontWeight.w600,
          decoration: s.canResend
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: OtpTokens.accent,
        ),
      ),
    );
  }
}
