import 'package:flutter/material.dart';

import '../theme/account_screen_tokens.dart';

class AccountQuickActionCard extends StatelessWidget {
  const AccountQuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.showUnreadDot = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool showUnreadDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = BorderRadius.circular(22);
    final iconBox = (w * 0.16).clamp(52.0, 58.0);
    final iconSize = (w * 0.09).clamp(28.0, 32.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.all((w * 0.04).clamp(16.0, 20.0)),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AccountScreenTokens.card, AccountScreenTokens.cardDeep],
            ),
            border: Border.all(color: AccountScreenTokens.border),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AccountScreenTokens.iconWell,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SizedBox(
                      width: iconBox,
                      height: iconBox,
                      child: Icon(
                        icon,
                        color: AccountScreenTokens.accent,
                        size: iconSize,
                      ),
                    ),
                  ),
                  SizedBox(height: (w * 0.03).clamp(10.0, 14.0)),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AccountScreenTokens.white,
                      fontSize: (w * 0.035).clamp(13.0, 14.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: (w * 0.012).clamp(4.0, 6.0)),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AccountScreenTokens.walletGreen,
                        fontSize: (w * 0.03).clamp(11.0, 12.0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
              if (showUnreadDot)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AccountScreenTokens.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AccountScreenTokens.accent.withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 6,
                        ),
                      ],
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
