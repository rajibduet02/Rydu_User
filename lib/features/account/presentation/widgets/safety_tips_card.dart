import 'package:flutter/material.dart';

import '../theme/safety_center_tokens.dart';

class SafetyTipsCard extends StatelessWidget {
  const SafetyTipsCard({super.key, required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.055).clamp(18.0, 22.0);
    final pad = (w * 0.045).clamp(18.0, 24.0);
    final titleSize = (w * 0.045).clamp(16.0, 18.0);
    final tipSize = (w * 0.035).clamp(13.0, 14.0);
    final bullet = (w * 0.06).clamp(22.0, 24.0);

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
            Text(
              'Safety Tips',
              style: TextStyle(
                color: SafetyCenterTokens.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
            for (var i = 0; i < tips.length; i++) ...[
              if (i > 0) SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: SafetyCenterTokens.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: bullet,
                      height: bullet,
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        color: SafetyCenterTokens.accent,
                        size: bullet * 0.55,
                      ),
                    ),
                  ),
                  SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
                  Expanded(
                    child: Text(
                      tips[i],
                      style: TextStyle(
                        color: SafetyCenterTokens.muted,
                        fontSize: tipSize,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
