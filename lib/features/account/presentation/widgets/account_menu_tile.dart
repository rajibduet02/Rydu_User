import 'package:flutter/material.dart';

import '../theme/account_screen_tokens.dart';

class AccountMenuTile extends StatelessWidget {
  const AccountMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLogout = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final iconBox = (w * 0.12).clamp(42.0, 46.0);
    final iconColor = isLogout
        ? AccountScreenTokens.logoutRed
        : AccountScreenTokens.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: (w * 0.035).clamp(14.0, 18.0),
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AccountScreenTokens.iconWell,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: iconBox,
                  height: iconBox,
                  child: Icon(icon, color: iconColor, size: iconBox * 0.48),
                ),
              ),
              SizedBox(width: (w * 0.04).clamp(14.0, 16.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AccountScreenTokens.white,
                        fontSize: (w * 0.042).clamp(15.0, 16.0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: (w * 0.008).clamp(2.0, 4.0)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AccountScreenTokens.muted,
                        fontSize: (w * 0.035).clamp(13.0, 14.0),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AccountScreenTokens.muted,
                size: (w * 0.07).clamp(24.0, 26.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
