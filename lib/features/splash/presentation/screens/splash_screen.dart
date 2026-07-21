import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../theme/splash_layout.dart';
import '../theme/splash_tokens.dart';
import '../widgets/splash_backdrop.dart';
import '../widgets/splash_loading_dots.dart';

/// Minimal splash: solid navy, centered “RYD U”, white tagline, blue loading dots.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _introEase;
  late final Animation<double> _taglineFade;
  late final Animation<double> _dotsFade;
  late final Animation<Offset> _taglineSlide;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _introEase = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );
    _taglineFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.28, 1.0, curve: Curves.easeOut),
    );
    _dotsFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.28, 1.0, curve: Curves.easeOut),
          ),
        );
    _introController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await ref.read(authSessionProvider.notifier).restore();
    if (!mounted) return;

    final session = ref.read(authSessionProvider);
    if (session.isAuthenticated) {
      try {
        // Prefer Home card over forced Finding Driver navigation.
        await ref
            .read(rideBookingControllerProvider.notifier)
            .restoreActiveBooking(navigate: false)
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        // Continue to home if active-booking restore fails.
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _navigateTo(session.isAuthenticated ? RouteNames.home : RouteNames.auth);
  }

  void _navigateTo(String destination) {
    if (!mounted || _navigated) return;
    _navigated = true;
    ref.read(goRouterProvider).go(destination);
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashTokens.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SplashBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                final logoSize = SplashLayout.logoFontSize(w);
                final taglineSize = SplashLayout.taglineFontSize(w);
                final dotSize = SplashLayout.dotSize(w);
                final dotGap = SplashLayout.dotGap(w);

                return SizedBox.expand(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: SplashLayout.maxContentWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SplashLayout.horizontalPadding,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _introController,
                              builder: (context, child) {
                                final introT = _introEase.value;
                                final scale = 0.88 + 0.12 * introT;
                                final fade = introT;
                                return Opacity(
                                  opacity: fade,
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Text(
                                      'RYD U',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: SplashTokens.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: logoSize,
                                        height: 1.05,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(
                              height: SplashLayout.spacingLogoToTagline,
                            ),
                            FadeTransition(
                              opacity: _taglineFade,
                              child: SlideTransition(
                                position: _taglineSlide,
                                child: Text(
                                  'Move Smarter',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: SplashTokens.white,
                                    fontSize: taglineSize,
                                    fontWeight: FontWeight.w400,
                                    height: 1.3,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: SplashLayout.spacingTaglineToDots(h),
                            ),
                            FadeTransition(
                              opacity: _dotsFade,
                              child: SplashLoadingDots(
                                dotSize: dotSize,
                                gap: dotGap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
