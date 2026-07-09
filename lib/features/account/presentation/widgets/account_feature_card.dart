import 'package:flutter/material.dart';

import '../theme/account_screen_tokens.dart';

enum AccountFeatureVariant { standard, membership, driver }

class AccountFeatureCard extends StatelessWidget {
  const AccountFeatureCard({
    super.key,
    this.leadingIcon,
    required this.title,
    this.showNewTag = false,
    required this.subtitle,
    required this.linkLabel,
    this.trailingEmoji,
    this.trailing,
    this.variant = AccountFeatureVariant.standard,
    this.linkColor,
    required this.onTap,
  });

  final IconData? leadingIcon;
  final String title;
  final bool showNewTag;
  final String subtitle;
  final String linkLabel;
  final String? trailingEmoji;
  final Widget? trailing;
  final AccountFeatureVariant variant;
  final Color? linkColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = BorderRadius.circular(22);
    final titleSize = (w * 0.045).clamp(16.0, 18.0);
    final bodySize = (w * 0.035).clamp(13.0, 14.0);
    final linkSize = (w * 0.035).clamp(13.0, 14.0);

    final borderColor = variant == AccountFeatureVariant.membership
        ? AccountScreenTokens.gold.withValues(alpha: 0.45)
        : variant == AccountFeatureVariant.driver
        ? AccountScreenTokens.green.withValues(alpha: 0.45)
        : AccountScreenTokens.border;
    final borderWidth = variant == AccountFeatureVariant.standard ? 1.0 : 2.0;

    final gradientBg = variant == AccountFeatureVariant.membership
        ? LinearGradient(
            colors: [
              AccountScreenTokens.gold.withValues(alpha: 0.12),
              AccountScreenTokens.gold.withValues(alpha: 0.05),
            ],
          )
        : variant == AccountFeatureVariant.driver
        ? LinearGradient(
            colors: [
              AccountScreenTokens.green.withValues(alpha: 0.12),
              AccountScreenTokens.green.withValues(alpha: 0.05),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AccountScreenTokens.card, AccountScreenTokens.cardDeep],
          );

    final effectiveLinkColor =
        linkColor ??
        (variant == AccountFeatureVariant.membership
            ? AccountScreenTokens.gold
            : variant == AccountFeatureVariant.driver
            ? AccountScreenTokens.green
            : AccountScreenTokens.accent);

    final iconColor = variant == AccountFeatureVariant.membership
        ? AccountScreenTokens.gold
        : variant == AccountFeatureVariant.driver
        ? AccountScreenTokens.green
        : AccountScreenTokens.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.all((w * 0.045).clamp(16.0, 20.0)),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: gradientBg,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (leadingIcon != null) ...[
                          Icon(
                            leadingIcon,
                            size: (w * 0.055).clamp(20.0, 22.0),
                            color: iconColor,
                          ),
                          SizedBox(width: (w * 0.02).clamp(8.0, 10.0)),
                        ],
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: AccountScreenTokens.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (showNewTag) ...[
                          SizedBox(width: (w * 0.02).clamp(6.0, 8.0)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AccountScreenTokens.newOrange,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'New',
                              style: TextStyle(
                                color: AccountScreenTokens.white,
                                fontSize: (w * 0.028).clamp(10.0, 11.0),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AccountScreenTokens.muted,
                        fontSize: bodySize,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: (w * 0.025).clamp(8.0, 12.0)),
                    Row(
                      children: [
                        Text(
                          linkLabel,
                          style: TextStyle(
                            color: effectiveLinkColor,
                            fontSize: linkSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: effectiveLinkColor,
                          size: (w * 0.055).clamp(18.0, 20.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: EdgeInsets.only(left: (w * 0.02).clamp(8.0, 10.0)),
                  child: trailing!,
                )
              else if (trailingEmoji != null)
                Padding(
                  padding: EdgeInsets.only(left: (w * 0.02).clamp(8.0, 10.0)),
                  child: Text(
                    trailingEmoji!,
                    style: TextStyle(fontSize: (w * 0.12).clamp(40.0, 48.0)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular progress for Safety Checkup (e.g. 1/5).
class AccountSafetyProgressRing extends StatelessWidget {
  const AccountSafetyProgressRing({
    super.key,
    required this.progress,
    required this.total,
  });

  final int progress;
  final int total;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = (w * 0.18).clamp(56.0, 64.0);
    final t = total <= 0 ? 1 : total;
    final v = (progress / t).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: 4,
              backgroundColor: AccountScreenTokens.border,
              color: AccountScreenTokens.accent,
            ),
          ),
          Text(
            '$progress/$total',
            style: TextStyle(
              color: AccountScreenTokens.white,
              fontSize: (w * 0.032).clamp(12.0, 13.0),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
