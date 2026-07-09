import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/auth_screen_tokens.dart';

class AuthTermsFooter extends StatefulWidget {
  const AuthTermsFooter({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  State<AuthTermsFooter> createState() => _AuthTermsFooterState();
}

class _AuthTermsFooterState extends State<AuthTermsFooter> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = widget.onTermsTap;
    _privacyTap = TapGestureRecognizer()..onTap = widget.onPrivacyTap;
  }

  @override
  void didUpdateWidget(covariant AuthTermsFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTermsTap != widget.onTermsTap) {
      _termsTap.onTap = widget.onTermsTap;
    }
    if (oldWidget.onPrivacyTap != widget.onPrivacyTap) {
      _privacyTap.onTap = widget.onPrivacyTap;
    }
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.032).clamp(12.0, 14.0);
    final linkStyle = TextStyle(
      color: AuthScreenTokens.link,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    );
    final bodyStyle = TextStyle(
      color: AuthScreenTokens.muted,
      fontSize: fontSize,
      height: 1.45,
    );

    return Text.rich(
      TextSpan(
        style: bodyStyle,
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: linkStyle,
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyTap,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
