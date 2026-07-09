import 'package:flutter/material.dart';

import '../theme/auth_screen_tokens.dart';

/// Outlined social / secondary auth action (matches React secondary buttons).
class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.leading,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget leading;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.04).clamp(15.0, 16.0);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AuthScreenTokens.white,
        backgroundColor: AuthScreenTokens.card,
        side: const BorderSide(color: AuthScreenTokens.border),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuthScreenTokens.radiusButton),
        ),
        textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AuthScreenTokens.accent.withValues(alpha: 0.9),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [leading, const SizedBox(width: 12), Text(label)],
            ),
    );
  }
}
