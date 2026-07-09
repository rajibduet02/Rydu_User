import 'package:flutter/material.dart';

import '../theme/activity_screen_tokens.dart';

/// Pill chip for filter bottom sheet rows.
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final padH = (w * 0.045).clamp(16.0, 22.0);
    final padV = (w * 0.028).clamp(10.0, 14.0);
    final fontSize = (w * 0.038).clamp(14.0, 15.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            color: selected
                ? ActivityScreenTokens.white
                : ActivityScreenTokens.chipUnselectedBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? ActivityScreenTokens.white
                  : ActivityScreenTokens.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: (w * 0.02).clamp(6.0, 8.0)),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? ActivityScreenTokens.onLight
                      : ActivityScreenTokens.muted,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
