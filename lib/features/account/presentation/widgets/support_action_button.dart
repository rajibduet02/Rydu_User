import 'package:flutter/material.dart';

import '../theme/call_support_tokens.dart';

enum SupportActionButtonVariant { primary, secondary }

class SupportActionButton extends StatelessWidget {
  const SupportActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SupportActionButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final SupportActionButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final height = (w * 0.14).clamp(52.0, 56.0);
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final fontSize = (w * 0.042).clamp(15.0, 16.0);

    final isPrimary = variant == SupportActionButtonVariant.primary;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: isPrimary
          ? FilledButton(
              onPressed: isLoading ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: CallSupportTokens.accent,
                foregroundColor: CallSupportTokens.buttonTextDark,
                disabledBackgroundColor: CallSupportTokens.accent.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                elevation: 0,
              ),
              child: _buildChild(fontSize, isPrimary),
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: CallSupportTokens.accent,
                side: const BorderSide(color: CallSupportTokens.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              child: _buildChild(fontSize, isPrimary),
            ),
    );
  }

  Widget _buildChild(double fontSize, bool isPrimary) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isPrimary
              ? CallSupportTokens.buttonTextDark
              : CallSupportTokens.accent,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: fontSize + 4,
            color: isPrimary
                ? CallSupportTokens.buttonTextDark
                : CallSupportTokens.accent,
          ),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
        ),
      ],
    );
  }
}
