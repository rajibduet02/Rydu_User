import 'package:flutter/material.dart';

import '../theme/faqs_tokens.dart';

class FaqCategoryChip extends StatelessWidget {
  const FaqCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.06).clamp(22.0, 26.0);

    return Padding(
      padding: EdgeInsets.only(right: (w * 0.025).clamp(8.0, 10.0)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: (w * 0.045).clamp(16.0, 18.0),
              vertical: (w * 0.025).clamp(10.0, 12.0),
            ),
            decoration: BoxDecoration(
              color: isSelected ? FaqsTokens.card : FaqsTokens.iconWell,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: isSelected
                    ? FaqsTokens.accentSolid.withValues(alpha: 0.6)
                    : FaqsTokens.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? FaqsTokens.white : FaqsTokens.muted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: (w * 0.035).clamp(13.0, 14.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
