import 'package:flutter/material.dart';

import '../theme/auth_screen_tokens.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key, this.phone});

  /// E164 or formatted phone passed from [RouteNames.otp] query `?phone=`.
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final raw = phone;
    final String? decoded = (raw != null && raw.isNotEmpty)
        ? Uri.decodeComponent(raw)
        : null;

    return Scaffold(
      backgroundColor: AuthScreenTokens.bg,
      appBar: AppBar(
        backgroundColor: AuthScreenTokens.bg,
        foregroundColor: AuthScreenTokens.white,
        title: const Text('OTP Verification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (decoded != null) ...[
                Text(
                  'Code sent to $decoded',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AuthScreenTokens.muted),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'OTP Verification',
                style: TextStyle(color: AuthScreenTokens.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
