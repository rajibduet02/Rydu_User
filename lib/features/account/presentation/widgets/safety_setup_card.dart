import 'package:flutter/material.dart';

import '../theme/safety_center_tokens.dart';

class SafetySetupCard extends StatelessWidget {
  const SafetySetupCard({
    super.key,
    required this.configuredCount,
    required this.totalCount,
    required this.progress,
  });

  final int configuredCount;
  final int totalCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.07).clamp(22.0, 28.0);
    final pad = (w * 0.045).clamp(18.0, 24.0);
    final titleSize = (w * 0.05).clamp(18.0, 20.0);
    final subSize = (w * 0.035).clamp(13.0, 14.0);
    final shieldSize = (w * 0.2).clamp(72.0, 80.0);
    final iconInner = (w * 0.1).clamp(36.0, 40.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SafetyCenterTokens.accentDeep.withValues(alpha: 0.10),
            SafetyCenterTokens.accentSoft.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: SafetyCenterTokens.accent.withValues(alpha: 0.40),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: SafetyCenterTokens.accent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: shieldSize,
              height: shieldSize,
              child: Icon(
                Icons.shield_outlined,
                color: SafetyCenterTokens.accent,
                size: iconInner,
              ),
            ),
          ),
          SizedBox(width: (w * 0.04).clamp(14.0, 16.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Safety Setup',
                  style: TextStyle(
                    color: SafetyCenterTokens.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: (w * 0.01).clamp(4.0, 6.0)),
                Text(
                  '$configuredCount of $totalCount features configured',
                  style: TextStyle(
                    color: SafetyCenterTokens.muted,
                    fontSize: subSize,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: (w * 0.025).clamp(10.0, 12.0)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: (w * 0.012).clamp(6.0, 8.0),
                    backgroundColor: SafetyCenterTokens.border,
                    color: SafetyCenterTokens.accent,
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
