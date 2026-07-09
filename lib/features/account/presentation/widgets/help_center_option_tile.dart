import 'package:flutter/material.dart';

import '../theme/help_center_tokens.dart';

class HelpCenterOptionTile extends StatelessWidget {
  const HelpCenterOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.055).clamp(18.0, 22.0);
    final iconBox = (w * 0.14).clamp(52.0, 56.0);
    final iconInner = (w * 0.07).clamp(26.0, 28.0);
    final titleSize = (w * 0.045).clamp(16.0, 18.0);
    final subSize = (w * 0.035).clamp(13.0, 14.0);
    final pad = (w * 0.04).clamp(16.0, 20.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HelpCenterTokens.cardTop, HelpCenterTokens.cardBottom],
            ),
            border: Border.all(color: HelpCenterTokens.border),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    width: iconBox,
                    height: iconBox,
                    child: Icon(icon, color: accentColor, size: iconInner),
                  ),
                ),
                SizedBox(width: (w * 0.035).clamp(14.0, 16.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: HelpCenterTokens.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: (w * 0.008).clamp(4.0, 6.0)),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: HelpCenterTokens.muted,
                          fontSize: subSize,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: HelpCenterTokens.muted,
                  size: (w * 0.07).clamp(26.0, 28.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
