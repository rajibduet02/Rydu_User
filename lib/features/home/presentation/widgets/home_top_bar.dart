import 'package:flutter/material.dart';

import '../theme/home_screen_tokens.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.onLocationTap,
    required this.onNotificationTap,
    this.hasUnreadNotification = true,
  });

  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  final bool hasUnreadNotification;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final btn = (w * 0.11).clamp(40.0, 44.0);
    final logoSize = (w * 0.075).clamp(26.0, 32.0);

    return Row(
      children: [
        _CircleIconButton(
          size: btn,
          onTap: onLocationTap,
          child: Icon(
            Icons.location_on_outlined,
            color: HomeScreenTokens.muted,
            size: btn * 0.45,
          ),
        ),
        Expanded(
          child: Text(
            'RYD U',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: HomeScreenTokens.white,
              fontSize: logoSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        _CircleIconButton(
          size: btn,
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: HomeScreenTokens.muted,
                size: btn * 0.45,
              ),
              if (hasUnreadNotification)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: HomeScreenTokens.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: HomeScreenTokens.accent.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.size,
    required this.onTap,
    required this.child,
  });

  final double size;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HomeScreenTokens.surface,
            border: Border.all(color: HomeScreenTokens.border),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
