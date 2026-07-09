import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/family_profile_provider.dart';
import '../theme/family_profile_tokens.dart';
import '../widgets/family_feature_tile.dart';
import '../widgets/family_profile_buttons.dart';

class FamilyProfileScreen extends ConsumerWidget {
  const FamilyProfileScreen({super.key});

  void _popOrAccount(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyProfileControllerProvider);
    final c = ref.read(familyProfileControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.065).clamp(24.0, 28.0);
    final subtitleSize = (w * 0.038).clamp(14.0, 15.0);
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.28).clamp(
      200.0,
      260.0,
    );

    return Scaffold(
      backgroundColor: FamilyProfileTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: heroHeight,
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: FamilyProfileTokens.hero,
                              ),
                              // TODO: Replace with family hero image asset when available.
                              child: SizedBox.expand(),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: hPad - 12,
                            child: IconButton(
                              onPressed: () => _popOrAccount(context),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: FamilyProfileTokens.white,
                                size: (w * 0.05).clamp(20.0, 22.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a Family profile',
                            style: TextStyle(
                              color: FamilyProfileTokens.white,
                              fontWeight: FontWeight.w700,
                              fontSize: titleSize,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: (w * 0.025).clamp(10.0, 12.0)),
                          Text(
                            'Support teens, adults, and seniors with:',
                            style: TextStyle(
                              color: FamilyProfileTokens.subtitle,
                              fontSize: subtitleSize,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: (w * 0.07).clamp(28.0, 32.0)),
                          const FamilyFeatureTile(
                            icon: Icons.shield_outlined,
                            title: 'Enhanced safety features',
                            description:
                                'Get live trip tracking for all members and built-in safety tools for teens.',
                          ),
                          const FamilyFeatureTile(
                            icon: Icons.smartphone_outlined,
                            title: 'Easier booking',
                            description:
                                'Teens can request their own rides and older adults can use a simplified app.',
                          ),
                          const FamilyFeatureTile(
                            icon: Icons.people_outline_rounded,
                            title: 'Family savings',
                            description:
                                'Share Uber One benefits, special promos, and family ride passes.',
                          ),
                          if (state.errorMessage != null) ...[
                            Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: FamilyProfileTokens.border,
            ),
            FamilyProfileButtons(
              isLoading: state.isLoading,
              onAdultTap: c.selectAdult,
              onTeenTap: c.selectTeen,
            ),
          ],
        ),
      ),
    );
  }
}
