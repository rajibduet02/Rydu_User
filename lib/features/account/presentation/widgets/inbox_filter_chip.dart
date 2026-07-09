import 'package:flutter/material.dart';

import '../theme/inbox_tokens.dart';

class InboxFilterChip extends StatelessWidget {
  const InboxFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final padH = (w * 0.04).clamp(14.0, 16.0);
    final padV = (w * 0.022).clamp(8.0, 10.0);
    final fontSize = (w * 0.035).clamp(13.0, 14.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            color: selected ? InboxTokens.accent : InboxTokens.iconWell,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? InboxTokens.accent : InboxTokens.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? InboxTokens.white : InboxTokens.muted,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
