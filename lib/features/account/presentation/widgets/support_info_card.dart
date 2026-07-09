import 'package:flutter/material.dart';

import '../theme/call_support_tokens.dart';

enum SupportInfoCardVariant { standard, emergency, secureLine }

class SupportInfoCard extends StatelessWidget {
  const SupportInfoCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.access_time_rounded,
    this.variant = SupportInfoCardVariant.standard,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final SupportInfoCardVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (variant == SupportInfoCardVariant.secureLine) {
      return _SecureLineCard(title: title, onTap: onTap);
    }

    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final pad = (w * 0.045).clamp(16.0, 18.0);
    final iconBox = (w * 0.11).clamp(42.0, 48.0);
    final titleSize = (w * 0.042).clamp(15.0, 16.0);
    final bodySize = (w * 0.035).clamp(13.0, 14.0);

    final titleColor = variant == SupportInfoCardVariant.emergency
        ? CallSupportTokens.emergencyTitle
        : CallSupportTokens.white;

    final child = Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: CallSupportTokens.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: CallSupportTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: CallSupportTokens.iconWell,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CallSupportTokens.border.withValues(alpha: 0.8),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: CallSupportTokens.muted,
              size: iconBox * 0.48,
            ),
          ),
          SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: (w * 0.02).clamp(6.0, 8.0)),
                Text(
                  description,
                  style: TextStyle(
                    color: CallSupportTokens.muted,
                    fontSize: bodySize,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _SecureLineCard extends StatelessWidget {
  const _SecureLineCard({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final pad = (w * 0.045).clamp(16.0, 18.0);
    final titleSize = (w * 0.042).clamp(15.0, 16.0);

    final content = Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: CallSupportTokens.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CallSupportTokens.cardDeep,
            CallSupportTokens.card,
            const Color(0xFF1E293B).withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SECURE LINE',
            style: TextStyle(
              color: CallSupportTokens.secureLabel,
              fontSize: titleSize * 0.75,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: CallSupportTokens.white,
              fontWeight: FontWeight.w800,
              fontSize: titleSize + 1,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }
}
