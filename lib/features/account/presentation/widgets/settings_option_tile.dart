import 'package:flutter/material.dart';

import '../theme/settings_screen_tokens.dart';

class SettingsOptionTile extends StatelessWidget {
  const SettingsOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.05).clamp(18.0, 20.0);
    final hPad = (w * 0.045).clamp(16.0, 20.0);
    final vPad = (w * 0.04).clamp(16.0, 20.0);
    final iconBox = (w * 0.12).clamp(44.0, 48.0);
    final iconInnerRadius = (w * 0.028).clamp(10.0, 12.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SettingsScreenTokens.cardTop,
                SettingsScreenTokens.cardBottom,
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: SettingsScreenTokens.border),
          ),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: SettingsScreenTokens.iconWell,
                  borderRadius: BorderRadius.circular(iconInnerRadius),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: SettingsScreenTokens.accent,
                  size: iconBox * 0.48,
                ),
              ),
              SizedBox(width: (w * 0.035).clamp(14.0, 16.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SettingsScreenTokens.white,
                        fontWeight: FontWeight.w600,
                        fontSize: (w * 0.042).clamp(15.0, 16.0),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: (w * 0.012).clamp(4.0, 6.0)),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SettingsScreenTokens.muted,
                        fontSize: (w * 0.035).clamp(13.0, 14.0),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: SettingsScreenTokens.muted,
                size: (w * 0.065).clamp(24.0, 28.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
