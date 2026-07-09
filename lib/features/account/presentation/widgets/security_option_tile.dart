import 'package:flutter/material.dart';

import '../theme/security_screen_tokens.dart';

class SecurityOptionTile extends StatelessWidget {
  const SecurityOptionTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final subtitleSize = (w * 0.034).clamp(13.0, 14.0);
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (w * 0.045).clamp(16.0, 18.0),
                vertical: hasSubtitle
                    ? (w * 0.04).clamp(14.0, 16.0)
                    : (w * 0.045).clamp(16.0, 18.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: SecurityScreenTokens.white,
                            fontWeight: FontWeight.w600,
                            fontSize: titleSize,
                          ),
                        ),
                        if (hasSubtitle) ...[
                          SizedBox(height: (w * 0.015).clamp(5.0, 6.0)),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: SecurityScreenTokens.muted,
                              fontSize: subtitleSize,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: SecurityScreenTokens.muted,
                    size: (w * 0.06).clamp(22.0, 24.0),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: SecurityScreenTokens.border,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
