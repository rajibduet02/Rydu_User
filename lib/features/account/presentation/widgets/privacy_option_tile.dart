import 'package:flutter/material.dart';

import '../theme/privacy_and_data_tokens.dart';

class PrivacyOptionTile extends StatelessWidget {
  const PrivacyOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final subtitleSize = (w * 0.034).clamp(13.0, 14.0);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (w * 0.045).clamp(16.0, 18.0),
                vertical: (w * 0.04).clamp(14.0, 16.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: PrivacyAndDataTokens.white,
                            fontWeight: FontWeight.w700,
                            fontSize: titleSize,
                          ),
                        ),
                        SizedBox(height: (w * 0.015).clamp(5.0, 6.0)),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: PrivacyAndDataTokens.muted,
                            fontSize: subtitleSize,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: PrivacyAndDataTokens.muted,
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
            color: PrivacyAndDataTokens.border,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
