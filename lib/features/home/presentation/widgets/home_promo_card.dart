import 'package:flutter/material.dart';

import '../theme/home_screen_tokens.dart';

enum HomePromoStyle { green, dark, blue, darkOutlined }

class HomePromoCard extends StatelessWidget {
  const HomePromoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.style,
    required this.backgroundEmoji,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final HomePromoStyle style;
  final String backgroundEmoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final height = (w * 0.34).clamp(118.0, 140.0);
    final radius = BorderRadius.circular(16);
    final titleSize = (w * 0.038).clamp(14.0, 16.0);
    final subSize = (w * 0.028).clamp(11.0, 13.0);
    final emojiBackdrop = (w * 0.22).clamp(72.0, 96.0);

    final BoxDecoration decoration;
    switch (style) {
      case HomePromoStyle.green:
        decoration = BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HomeScreenTokens.promoGreenStart,
              HomeScreenTokens.promoGreenEnd,
            ],
          ),
        );
        break;
      case HomePromoStyle.blue:
        decoration = BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [HomeScreenTokens.accent, HomeScreenTokens.accentSoft],
          ),
          boxShadow: [
            BoxShadow(
              color: HomeScreenTokens.accent.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        );
        break;
      case HomePromoStyle.dark:
      case HomePromoStyle.darkOutlined:
        decoration = BoxDecoration(
          borderRadius: radius,
          color: HomeScreenTokens.surface,
          border: Border.all(color: HomeScreenTokens.border),
        );
        break;
    }

    final subtitleColor =
        style == HomePromoStyle.dark || style == HomePromoStyle.darkOutlined
        ? HomeScreenTokens.muted
        : HomeScreenTokens.white.withValues(alpha: 0.88);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          height: height,
          decoration: decoration,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              Positioned(
                right: -4,
                bottom: -8,
                child: Opacity(
                  opacity:
                      style == HomePromoStyle.dark ||
                          style == HomePromoStyle.darkOutlined
                      ? 0.12
                      : 0.22,
                  child: Text(
                    backgroundEmoji,
                    style: TextStyle(fontSize: emojiBackdrop),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: HomeScreenTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: subSize,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
