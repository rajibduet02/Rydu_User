import 'package:flutter/material.dart';

import '../theme/safety_resources_tokens.dart';

class SafetyTipTile extends StatelessWidget {
  const SafetyTipTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.onTap,
    this.expandedBody,
    this.showDivider = true,
  });

  final String title;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onTap;
  final String? expandedBody;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final bodySize = (w * 0.035).clamp(13.0, 14.0);

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
                children: [
                  Icon(
                    icon,
                    color: SafetyResourcesTokens.muted,
                    size: (w * 0.055).clamp(22.0, 24.0),
                  ),
                  SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: SafetyResourcesTokens.white,
                        fontWeight: FontWeight.w600,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: SafetyResourcesTokens.muted,
                      size: (w * 0.065).clamp(24.0, 28.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded && expandedBody != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              (w * 0.045).clamp(16.0, 18.0),
              0,
              (w * 0.045).clamp(16.0, 18.0),
              (w * 0.035).clamp(12.0, 14.0),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                expandedBody!,
                style: TextStyle(
                  color: SafetyResourcesTokens.muted,
                  fontSize: bodySize,
                  height: 1.45,
                ),
              ),
            ),
          ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: SafetyResourcesTokens.border,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
