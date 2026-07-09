import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/welcome_controller.dart';
import '../theme/welcome_tokens.dart';
import '../widgets/welcome_cta_section.dart';
import '../widgets/welcome_hero_section.dart';
import '../widgets/welcome_promo_section.dart';

/// Welcome / first ride help (React `WelcomeScreen.tsx` + Figma reference).
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(welcomeControllerProvider.notifier).reset();
    });
  }

  Future<void> _onSeeAllOffers() async {
    ref.read(welcomeControllerProvider.notifier).openOffers();
    if (!mounted) return;
    await context.push(RouteNames.offers);
  }

  Future<void> _onNeedHelp() async {
    final ok = await ref
        .read(welcomeControllerProvider.notifier)
        .startFirstRideHelp();
    if (!mounted || !ok) return;
    context.push(
      RouteNames.rideBooking,
      extra: <String, Object?>{'selectedType': 'Ride'},
    );
  }

  Future<void> _onNoThanks() async {
    final ok = await ref
        .read(welcomeControllerProvider.notifier)
        .skipFirstRideHelp();
    if (!mounted || !ok) return;
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(welcomeControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = (w * 0.06).clamp(20.0, 28.0);
    final titleSize = (w * 0.09).clamp(28.0, 34.0);
    final subtitleSize = (w * 0.045).clamp(16.0, 18.0);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: WelcomeTokens.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      (constraints.maxHeight * 0.015).clamp(8.0, 20.0),
                      horizontal,
                      8,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WelcomePromoSection(onSeeAllOffers: _onSeeAllOffers),
                        SizedBox(
                          height: (constraints.maxHeight * 0.02).clamp(
                            12.0,
                            24.0,
                          ),
                        ),
                        const WelcomeHeroSection(),
                        SizedBox(
                          height: (constraints.maxHeight * 0.03).clamp(
                            16.0,
                            32.0,
                          ),
                        ),
                        Text(
                          'Welcome to RYD U',
                          style: TextStyle(
                            color: WelcomeTokens.white,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: WelcomeTokens.titleBottom),
                        Text(
                          'Want help getting your first ride?',
                          style: TextStyle(
                            color: WelcomeTokens.muted,
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                        if (s.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            s.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    8,
                    horizontal,
                    WelcomeTokens.spaceBottom + bottomPad,
                  ),
                  child: WelcomeCtaSection(
                    submitKind: s.submitKind,
                    onNeedHelp: _onNeedHelp,
                    onNoThanks: _onNoThanks,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
