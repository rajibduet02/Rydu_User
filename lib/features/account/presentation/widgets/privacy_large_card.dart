import 'package:flutter/material.dart';

import '../theme/privacy_and_data_tokens.dart';

class PrivacyLargeCard extends StatelessWidget {
  const PrivacyLargeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final subtitleSize = (w * 0.034).clamp(13.0, 14.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.all((w * 0.045).clamp(16.0, 18.0)),
          decoration: BoxDecoration(
            color: PrivacyAndDataTokens.card,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: PrivacyAndDataTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: PrivacyAndDataTokens.white,
                size: (w * 0.055).clamp(22.0, 24.0),
              ),
              SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
              Text(
                title,
                style: TextStyle(
                  color: PrivacyAndDataTokens.white,
                  fontWeight: FontWeight.w700,
                  fontSize: titleSize,
                ),
              ),
              SizedBox(height: (w * 0.015).clamp(5.0, 6.0)),
              Text(
                subtitle,
                style: TextStyle(
                  color: PrivacyAndDataTokens.muted,
                  fontSize: subtitleSize,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
