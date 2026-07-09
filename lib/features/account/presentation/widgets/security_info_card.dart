import 'package:flutter/material.dart';

import '../theme/security_screen_tokens.dart';

class SecurityInfoCard extends StatelessWidget {
  const SecurityInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final titleSize = (w * 0.042).clamp(15.0, 17.0);
    final bodySize = (w * 0.034).clamp(13.0, 14.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((w * 0.045).clamp(16.0, 18.0)),
      decoration: BoxDecoration(
        color: SecurityScreenTokens.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SecurityScreenTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: (w * 0.11).clamp(40.0, 44.0),
            height: (w * 0.11).clamp(40.0, 44.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: SecurityScreenTokens.protectionCircle,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: SecurityScreenTokens.white,
              size: (w * 0.055).clamp(22.0, 24.0),
            ),
          ),
          SizedBox(width: (w * 0.04).clamp(14.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Protection',
                  style: TextStyle(
                    color: SecurityScreenTokens.white,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                  ),
                ),
                SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
                Text(
                  'Your account is currently protected by standard protocols. '
                  'Enhance security by enabling multi-factor authentication below.',
                  style: TextStyle(
                    color: SecurityScreenTokens.subtitle,
                    fontSize: bodySize,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
