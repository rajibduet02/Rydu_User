import 'package:flutter/material.dart';

import '../theme/account_screen_tokens.dart';

/// Gold “RYD U One” pill (React membership chip).
class MembershipBadge extends StatelessWidget {
  const MembershipBadge({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.032).clamp(12.0, 14.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.03).clamp(10.0, 14.0),
            vertical: (w * 0.018).clamp(6.0, 8.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                AccountScreenTokens.accent.withValues(alpha: 0.22),
                AccountScreenTokens.accentSoft.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: AccountScreenTokens.accent.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: (w * 0.045).clamp(16.0, 18.0),
                color: AccountScreenTokens.gold,
              ),
              SizedBox(width: (w * 0.015).clamp(4.0, 6.0)),
              Text(
                label,
                style: TextStyle(
                  color: AccountScreenTokens.gold,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
