import 'package:flutter/material.dart';

import '../theme/welcome_tokens.dart';

/// Small promo tile with discount pill (React `WelcomeScreen` promo row).
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.discountLabel,
    this.isSelected = false,
    required this.onTap,
    this.width,
    this.height,
  });

  final String discountLabel;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final w = width ?? WelcomeTokens.promoCardWidth;
    final h = height ?? WelcomeTokens.promoCardHeight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WelcomeTokens.radiusPromo),
        child: Ink(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(WelcomeTokens.radiusPromo),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [WelcomeTokens.cardStart, WelcomeTokens.cardEnd],
            ),
            border: Border.all(
              color: isSelected ? WelcomeTokens.accent : WelcomeTokens.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 8,
                left: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: WelcomeTokens.discountRed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      discountLabel,
                      style: const TextStyle(
                        color: WelcomeTokens.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
