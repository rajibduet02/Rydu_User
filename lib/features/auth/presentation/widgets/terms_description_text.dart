import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/terms_screen_tokens.dart';

/// Wrapping body copy with tappable “Terms of Use” and “Privacy Notice” spans.
class TermsDescriptionText extends StatefulWidget {
  const TermsDescriptionText({
    super.key,
    required this.onTermsOfUseTap,
    required this.onPrivacyNoticeTap,
    this.fontSize = 17,
    this.height = 1.45,
  });

  final VoidCallback onTermsOfUseTap;
  final VoidCallback onPrivacyNoticeTap;
  final double fontSize;
  final double height;

  @override
  State<TermsDescriptionText> createState() => _TermsDescriptionTextState();
}

class _TermsDescriptionTextState extends State<TermsDescriptionText> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = widget.onTermsOfUseTap;
    _privacyTap = TapGestureRecognizer()..onTap = widget.onPrivacyNoticeTap;
  }

  @override
  void didUpdateWidget(covariant TermsDescriptionText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onTermsOfUseTap != widget.onTermsOfUseTap) {
      _termsTap.onTap = widget.onTermsOfUseTap;
    }
    if (oldWidget.onPrivacyNoticeTap != widget.onPrivacyNoticeTap) {
      _privacyTap.onTap = widget.onPrivacyNoticeTap;
    }
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  TextStyle _bodyStyle() => TextStyle(
    color: TermsScreenTokens.body,
    fontSize: widget.fontSize,
    height: widget.height,
    fontWeight: FontWeight.w400,
  );

  TextStyle _linkStyle() => TextStyle(
    color: TermsScreenTokens.link,
    fontSize: widget.fontSize,
    height: widget.height,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
    decorationColor: TermsScreenTokens.link,
  );

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: _bodyStyle(),
        children: [
          const TextSpan(
            text:
                'By selecting "I Agree" below, I have reviewed and agree to the ',
          ),
          TextSpan(
            text: 'Terms of Use',
            style: _linkStyle(),
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' and acknowledge the '),
          TextSpan(
            text: 'Privacy Notice',
            style: _linkStyle(),
            recognizer: _privacyTap,
          ),
          const TextSpan(text: '.\n'),
          const TextSpan(text: 'I am at least 18 years of age.'),
        ],
      ),
    );
  }
}
