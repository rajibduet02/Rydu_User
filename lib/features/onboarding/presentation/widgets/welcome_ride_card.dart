import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/welcome_tokens.dart';

/// Large rounded hero card with accent ride icon (Figma reference).
class WelcomeRideCard extends StatelessWidget {
  const WelcomeRideCard({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final side = (mq.width * 0.72).clamp(240.0, 360.0);
    final radius = (mq.width * 0.07).clamp(22.0, 30.0);
    final iconSize = (side * 0.28).clamp(56.0, 96.0);

    return SizedBox(
      width: side,
      height: side,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: WelcomeTokens.rideCardFill,
          border: Border.all(color: WelcomeTokens.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.85,
                    colors: [
                      WelcomeTokens.rideCardGlow.withValues(alpha: 0.45),
                      WelcomeTokens.rideCardFill,
                    ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
              Opacity(
                opacity: 0.35,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
                  child: Container(
                    width: side * 0.55,
                    height: side * 0.55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          WelcomeTokens.accent.withValues(alpha: 0.9),
                          WelcomeTokens.accentSoft.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // TODO: Replace with branded scooter / ride vector from design assets.
              Icon(
                Icons.electric_scooter_outlined,
                size: iconSize,
                color: WelcomeTokens.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
