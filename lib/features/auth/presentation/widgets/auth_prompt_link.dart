import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/auth_screen_tokens.dart';

/// Inline prompt with a tappable link, e.g. "Don't have an account? Sign Up".
class AuthPromptLink extends StatefulWidget {
  const AuthPromptLink({
    super.key,
    required this.prefix,
    required this.linkLabel,
    required this.onLinkTap,
    this.enabled = true,
    this.textAlign = TextAlign.center,
    this.prefixColor,
    this.linkColor,
  });

  final String prefix;
  final String linkLabel;
  final VoidCallback? onLinkTap;
  final bool enabled;
  final TextAlign textAlign;
  final Color? prefixColor;
  final Color? linkColor;

  @override
  State<AuthPromptLink> createState() => _AuthPromptLinkState();
}

class _AuthPromptLinkState extends State<AuthPromptLink> {
  late final TapGestureRecognizer _linkTap;

  @override
  void initState() {
    super.initState();
    _linkTap = TapGestureRecognizer()..onTap = _handleTap;
  }

  @override
  void didUpdateWidget(covariant AuthPromptLink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onLinkTap != widget.onLinkTap) {
      _linkTap.onTap = _handleTap;
    }
  }

  void _handleTap() {
    if (widget.enabled) widget.onLinkTap?.call();
  }

  @override
  void dispose() {
    _linkTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.038).clamp(14.0, 15.0);
    final bodyStyle = TextStyle(
      color: widget.prefixColor ?? AuthScreenTokens.muted,
      fontSize: fontSize,
      height: 1.4,
    );
    final linkStyle = TextStyle(
      color: widget.enabled
          ? (widget.linkColor ?? AuthScreenTokens.link)
          : (widget.prefixColor ?? AuthScreenTokens.muted).withValues(
              alpha: 0.5,
            ),
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    return Text.rich(
      TextSpan(
        style: bodyStyle,
        children: [
          TextSpan(text: widget.prefix),
          TextSpan(
            text: widget.linkLabel,
            style: linkStyle,
            recognizer: widget.enabled ? _linkTap : null,
          ),
        ],
      ),
      textAlign: widget.textAlign,
    );
  }
}
