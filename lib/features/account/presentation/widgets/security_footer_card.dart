import 'package:flutter/material.dart';

import '../theme/security_screen_tokens.dart';

class SecurityFooterCard extends StatelessWidget {
  const SecurityFooterCard({super.key, required this.onPrivacyPolicy});

  final VoidCallback onPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final bodySize = (w * 0.034).clamp(13.0, 14.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: (w * 0.05).clamp(18.0, 20.0),
        vertical: (w * 0.055).clamp(20.0, 24.0),
      ),
      decoration: BoxDecoration(
        color: SecurityScreenTokens.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SecurityScreenTokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shield_outlined,
            color: SecurityScreenTokens.muted,
            size: (w * 0.06).clamp(22.0, 24.0),
          ),
          SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
          Text(
            'Always keep your security information updated to prevent '
            'unauthorized access.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SecurityScreenTokens.white,
              fontSize: bodySize,
              height: 1.45,
            ),
          ),
          SizedBox(height: (w * 0.045).clamp(16.0, 18.0)),
          OutlinedButton(
            onPressed: onPrivacyPolicy,
            style: OutlinedButton.styleFrom(
              foregroundColor: SecurityScreenTokens.white,
              side: const BorderSide(color: SecurityScreenTokens.border),
              padding: EdgeInsets.symmetric(
                horizontal: (w * 0.08).clamp(28.0, 32.0),
                vertical: (w * 0.028).clamp(10.0, 12.0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: (w * 0.036).clamp(13.0, 14.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
