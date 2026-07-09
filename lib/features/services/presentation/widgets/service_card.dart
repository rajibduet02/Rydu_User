import 'package:flutter/material.dart';

import '../theme/services_screen_tokens.dart';

/// One tile in the services grid (discount pill, icon well, label).
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.label,
    required this.emoji,
    this.discountLabel,
    required this.iconAccent,
    required this.isDimmed,
    this.isSelected = false,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final String? discountLabel;
  final Color iconAccent;
  final bool isDimmed;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = BorderRadius.circular(24);
    final iconBox = (w * 0.2).clamp(64.0, 80.0);
    final emojiSize = (w * 0.09).clamp(32.0, 40.0);
    final titleSize = (w * 0.04).clamp(14.0, 16.0);

    return Opacity(
      opacity: isDimmed ? 0.75 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              color: ServicesScreenTokens.card,
              borderRadius: radius,
              border: Border.all(
                color: isSelected
                    ? ServicesScreenTokens.accent
                    : ServicesScreenTokens.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ServicesScreenTokens.accent.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (discountLabel != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ServicesScreenTokens.discountRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          discountLabel!,
                          style: const TextStyle(
                            color: ServicesScreenTokens.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              iconAccent.withValues(alpha: 0.22),
                              iconAccent.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                        child: SizedBox(
                          width: iconBox,
                          height: iconBox,
                          child: Center(
                            // TODO: Replace emoji with branded vector / bitmap assets.
                            child: Text(
                              emoji,
                              style: TextStyle(fontSize: emojiSize),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ServicesScreenTokens.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
