import 'package:flutter/material.dart';

import '../theme/home_screen_tokens.dart';

/// “Where to?” + “Later” row under the home top bar.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.onSearchTap,
    required this.onLaterTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onLaterTap;

  static const _radius = 18.0;
  static const _borderColor = HomeScreenTokens.border;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final barHeight = (w * 0.14).clamp(52.0, 58.0);
    final laterWidth = (w * 0.27).clamp(100.0, 112.0);
    final hPadSearch = (w * 0.045).clamp(16.0, 20.0);
    final gap = 12.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(_radius),
              child: Ink(
                height: barHeight,
                decoration: BoxDecoration(
                  color: HomeScreenTokens.surface,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: _borderColor),
                ),
                padding: EdgeInsets.symmetric(horizontal: hPadSearch),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: HomeScreenTokens.muted,
                      size: (w * 0.055).clamp(20.0, 22.0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Where to?',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: HomeScreenTokens.muted,
                          fontSize: (w * 0.04).clamp(15.0, 16.0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: gap),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onLaterTap,
            borderRadius: BorderRadius.circular(_radius),
            child: Ink(
              height: barHeight,
              width: laterWidth,
              decoration: BoxDecoration(
                color: HomeScreenTokens.surface,
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: _borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: HomeScreenTokens.muted,
                    size: (w * 0.048).clamp(17.0, 19.0),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Later',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HomeScreenTokens.muted,
                        fontSize: (w * 0.038).clamp(14.0, 15.0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
