import 'package:flutter/material.dart';

import '../theme/home_screen_tokens.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.activeBackgroundColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Defaults to [HomeScreenTokens.accent] when null.
  final Color? activeColor;

  /// Defaults to [HomeScreenTokens.muted] when null.
  final Color? inactiveColor;

  /// Defaults to [HomeScreenTokens.navActiveBg] when null.
  final Color? activeBackgroundColor;

  static const _items = [
    _NavSpec(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavSpec(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Services'),
    _NavSpec(Icons.assignment_outlined, Icons.assignment_rounded, 'Activity'),
    _NavSpec(Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  Color get _active => activeColor ?? HomeScreenTokens.accent;
  Color get _inactive => inactiveColor ?? HomeScreenTokens.muted;
  Color get _activeBg => activeBackgroundColor ?? HomeScreenTokens.navActiveBg;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final outerH = (w * 0.045).clamp(20.0, 28.0);
    final outerV = (w * 0.028).clamp(10.0, 14.0);
    final radius = BorderRadius.circular((w * 0.09).clamp(28.0, 36.0));
    final barMinH = (w * 0.2).clamp(74.0, 86.0);

    return Container(
      constraints: BoxConstraints(minHeight: barMinH),
      decoration: BoxDecoration(
        color: HomeScreenTokens.surface.withValues(alpha: 0.98),
        borderRadius: radius,
        border: Border.all(
          color: HomeScreenTokens.border.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 14),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: HomeScreenTokens.accent.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(outerH, outerV, outerH, outerV),
        child: Row(
          children: List.generate(_items.length, (i) {
            final spec = _items[i];
            final active = i == currentIndex;
            return Expanded(
              child: _NavItem(
                spec: spec,
                active: active,
                activeColor: _active,
                inactiveColor: _inactive,
                activeBackgroundColor: _activeBg,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeBackgroundColor,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeBackgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final iconSize = (w * 0.058).clamp(22.0, 26.0);
    final labelSize = (w * 0.03).clamp(10.0, 12.0);
    final bubble = (w * 0.14).clamp(48.0, 56.0);
    final trackH = (w * 0.15).clamp(50.0, 58.0);

    final iconArea = SizedBox(
      height: trackH,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: bubble,
          height: bubble,
          child: Center(
            child: active
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: bubble,
                    height: bubble,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      spec.activeIcon,
                      size: iconSize,
                      color: activeColor,
                    ),
                  )
                : Icon(spec.icon, size: iconSize, color: inactiveColor),
          ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: activeColor.withValues(alpha: 0.12),
        highlightColor: activeColor.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconArea,
              const SizedBox(height: 4),
              Text(
                spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? activeColor : inactiveColor,
                  fontSize: labelSize,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
