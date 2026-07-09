import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../theme/faqs_tokens.dart';

class FaqSupportCard extends StatelessWidget {
  const FaqSupportCard({super.key, required this.onContactSupport});

  final VoidCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final pad = (w * 0.055).clamp(20.0, 24.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: FaqsTokens.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppDarkSurfaces.surfaceElevated.withValues(alpha: 0.95),
            AppDarkSurfaces.surfaceContainerLow.withValues(alpha: 0.98),
            FaqsTokens.cardDeep,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Can't find your answer?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: FaqsTokens.white,
              fontWeight: FontWeight.w800,
              fontSize: (w * 0.048).clamp(17.0, 19.0),
            ),
          ),
          SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
          Text(
            'Our dedicated support team is here to assist you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: FaqsTokens.muted,
              fontSize: (w * 0.035).clamp(13.0, 14.0),
              height: 1.4,
            ),
          ),
          SizedBox(height: (w * 0.045).clamp(16.0, 20.0)),
          SizedBox(
            height: (w * 0.12).clamp(48.0, 52.0),
            child: FilledButton(
              onPressed: onContactSupport,
              style: FilledButton.styleFrom(
                backgroundColor: FaqsTokens.accent,
                foregroundColor: FaqsTokens.buttonTextDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                elevation: 0,
              ),
              child: Text(
                'CONTACT SUPPORT',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: (w * 0.035).clamp(13.0, 14.0),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
