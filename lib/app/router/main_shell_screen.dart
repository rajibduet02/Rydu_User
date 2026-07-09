import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/theme/account_screen_tokens.dart';
import '../../features/activity/presentation/theme/activity_screen_tokens.dart';
import '../../features/home/presentation/theme/home_screen_tokens.dart';
import '../../features/home/presentation/widgets/home_bottom_nav.dart';
import '../../features/services/presentation/theme/services_screen_tokens.dart';
import '../theme/app_colors.dart';
import 'route_names.dart';

/// Shell for main tabs: [Stack] overlays floating [HomeBottomNav] on [navigationShell].
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const Color _shellBg = AppDarkSurfaces.scaffold;

  static int _tabIndexForLocation(String path) {
    if (path == RouteNames.services ||
        path.startsWith('${RouteNames.services}/')) {
      return 1;
    }
    if (path == RouteNames.activity ||
        path.startsWith('${RouteNames.activity}/')) {
      return 2;
    }
    if (path == RouteNames.account ||
        path.startsWith('${RouteNames.account}/')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabIndexForLocation(path);

    late final Color? activeColor;
    late final Color? inactiveColor;
    late final Color? activeBackgroundColor;

    switch (currentIndex) {
      case 1:
        activeColor = ServicesScreenTokens.accent;
        inactiveColor = ServicesScreenTokens.muted;
        activeBackgroundColor = ServicesScreenTokens.navActiveBg;
        break;
      case 2:
        activeColor = ActivityScreenTokens.accent;
        inactiveColor = ActivityScreenTokens.muted;
        activeBackgroundColor = ActivityScreenTokens.navActiveBg;
        break;
      case 3:
        activeColor = AccountScreenTokens.accent;
        inactiveColor = AccountScreenTokens.muted;
        activeBackgroundColor = AccountScreenTokens.navActiveBg;
        break;
      default:
        activeColor = HomeScreenTokens.accent;
        inactiveColor = HomeScreenTokens.muted;
        activeBackgroundColor = HomeScreenTokens.navActiveBg;
    }

    final bottomInset = 18 + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _shellBg,
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ColoredBox(color: _shellBg, child: navigationShell),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomInset,
            child: HomeBottomNav(
              currentIndex: currentIndex,
              onTap: (index) => navigationShell.goBranch(index),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              activeBackgroundColor: activeBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
