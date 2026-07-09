import 'package:flutter/material.dart';

import '../theme/safety_center_tokens.dart';

class SafetyActionCard extends StatelessWidget {
  const SafetyActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.actionLabel,
    required this.onAction,
    this.showConfiguredBadge = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String actionLabel;
  final VoidCallback onAction;
  final bool showConfiguredBadge;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.055).clamp(18.0, 22.0);
    final pad = (w * 0.04).clamp(16.0, 20.0);
    final titleSize = (w * 0.045).clamp(16.0, 18.0);
    final subSize = (w * 0.035).clamp(13.0, 14.0);
    final iconBox = (w * 0.14).clamp(52.0, 56.0);
    final iconInner = (w * 0.07).clamp(26.0, 28.0);
    final btnText = (w * 0.038).clamp(14.0, 15.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SafetyCenterTokens.cardTop, SafetyCenterTokens.cardBottom],
        ),
        border: Border.all(color: SafetyCenterTokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SizedBox(
                        width: iconBox,
                        height: iconBox,
                        child: Icon(icon, color: iconColor, size: iconInner),
                      ),
                    ),
                    if (showConfiguredBadge)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: SafetyCenterTokens.green,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Icon(
                              Icons.check_rounded,
                              color: SafetyCenterTokens.white,
                              size: (w * 0.045).clamp(14.0, 16.0),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: (w * 0.035).clamp(14.0, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: SafetyCenterTokens.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: (w * 0.008).clamp(4.0, 6.0)),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: SafetyCenterTokens.muted,
                          fontSize: subSize,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: SafetyCenterTokens.iconWell,
                foregroundColor: SafetyCenterTokens.white,
                padding: EdgeInsets.symmetric(
                  vertical: (w * 0.035).clamp(12.0, 14.0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: btnText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
