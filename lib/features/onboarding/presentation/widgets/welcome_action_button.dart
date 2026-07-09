import 'package:flutter/material.dart';

import '../theme/welcome_tokens.dart';
import '../../../../app/theme/app_colors.dart';

/// Primary (filled white) or secondary (outlined) pill CTA.
class WelcomeActionButton extends StatelessWidget {
  const WelcomeActionButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.pressedBackgroundColor,
  }) : _filled = true;

  const WelcomeActionButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize,
    this.isLoading = false,
  }) : _filled = false,
       backgroundColor = null,
       foregroundColor = null,
       disabledBackgroundColor = null,
       disabledForegroundColor = null,
       pressedBackgroundColor = null;

  final String label;
  final VoidCallback? onPressed;
  final bool _filled;
  final bool isLoading;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Color? pressedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context).width;
    final fs = fontSize ?? (mq * 0.042).clamp(15.0, 17.0);
    final radius = BorderRadius.circular(WelcomeTokens.radiusButton);
    final height = (mq * 0.14).clamp(50.0, 56.0);

    if (_filled) {
      final busy = isLoading;
      final enabled = onPressed != null && !busy;
      final bg = backgroundColor ?? WelcomeTokens.buttonFill;
      final fg = foregroundColor ?? WelcomeTokens.buttonText;
      final disabledBg = disabledBackgroundColor ?? WelcomeTokens.buttonFill;
      final disabledFg = disabledForegroundColor ?? AppDarkText.disabled;
      return Opacity(
        opacity: enabled ? 1 : 0.55,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            style:
                FilledButton.styleFrom(
                  backgroundColor: bg,
                  foregroundColor: fg,
                  disabledBackgroundColor: disabledBg,
                  disabledForegroundColor: disabledFg,
                  elevation: 10,
                  shadowColor: Colors.black38,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                  textStyle: TextStyle(
                    fontSize: fs,
                    fontWeight: FontWeight.w700,
                  ),
                ).copyWith(
                  overlayColor: pressedBackgroundColor != null
                      ? WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return pressedBackgroundColor;
                          }
                          return null;
                        })
                      : null,
                ),
            child: busy
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fg.withValues(alpha: 0.65),
                    ),
                  )
                : Text(label),
          ),
        ),
      );
    }

    final busy = isLoading;
    final enabled = onPressed != null && !busy;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: WelcomeTokens.white,
            side: BorderSide(
              color: WelcomeTokens.white.withValues(alpha: 0.85),
              width: 2,
            ),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: radius),
            textStyle: TextStyle(fontSize: fs, fontWeight: FontWeight.w700),
          ),
          child: busy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: WelcomeTokens.white,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}
