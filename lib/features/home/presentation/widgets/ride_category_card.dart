import 'package:flutter/material.dart';

import '../theme/home_screen_tokens.dart';

class RideCategoryCard extends StatelessWidget {
  const RideCategoryCard({
    super.key,
    required this.label,
    required this.emoji,
    this.discountLabel,
    required this.isSelected,
    required this.bookable,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final String? discountLabel;
  final bool isSelected;
  final bool bookable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = BorderRadius.circular(16);
    final emojiSize = (w * 0.07).clamp(26.0, 32.0);
    final labelSize = (w * 0.028).clamp(11.0, 13.0);

    return Opacity(
      opacity: bookable ? 1 : 0.75,
      child: Material(
        color: HomeScreenTokens.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: isSelected
                    ? HomeScreenTokens.accent
                    : HomeScreenTokens.border,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: HomeScreenTokens.accent.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    10,
                    discountLabel != null ? 18 : 12,
                    10,
                    12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: TextStyle(fontSize: emojiSize)),
                      SizedBox(height: (w * 0.015).clamp(4.0, 8.0)),
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: HomeScreenTokens.white,
                          fontSize: labelSize,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                if (discountLabel != null)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: HomeScreenTokens.discountRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        child: Text(
                          discountLabel!,
                          style: const TextStyle(
                            color: HomeScreenTokens.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
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
