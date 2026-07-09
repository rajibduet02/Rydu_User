import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/intercity_controller.dart' show IntercityOfferIds;
import '../providers/intercity_provider.dart';
import '../theme/intercity_tokens.dart';
import '../widgets/intercity_offer_card.dart';
import '../widgets/popular_destination_card.dart';
import '../widgets/ride_confidence_card.dart';

class IntercityScreen extends ConsumerStatefulWidget {
  const IntercityScreen({super.key});

  @override
  ConsumerState<IntercityScreen> createState() => _IntercityScreenState();
}

class _IntercityScreenState extends ConsumerState<IntercityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(intercityControllerProvider.notifier).loadIntercityData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(intercityControllerProvider);
    final c = ref.read(intercityControllerProvider.notifier);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final hPad = (MediaQuery.sizeOf(context).width * 0.06).clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: IntercityTokens.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      12,
                      hPad,
                      16 + bottomInset,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 1,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _CircleIconButton(
                                icon: Icons.chevron_left_rounded,
                                onTap: c.navigateBack,
                              ),
                              _CircleIconButton(
                                icon: Icons.help_outline_rounded,
                                onTap: c.openHelp,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Plan your intercity ride',
                            style: TextStyle(
                              color: IntercityTokens.white,
                              fontSize:
                                  (MediaQuery.sizeOf(context).width * 0.075)
                                      .clamp(26.0, 30.0),
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 20),
                          IntercityOfferCard(
                            onTap: () =>
                                c.selectOffer(IntercityOfferIds.defaultPromo),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Popular destinations',
                            style: TextStyle(
                              color: IntercityTokens.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (s.isLoading && s.popularDestinations.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: IntercityTokens.accent,
                                  ),
                                ),
                              ),
                            )
                          else
                            LayoutBuilder(
                              builder: (context, box) {
                                final gap = 12.0;
                                final half = (box.maxWidth - gap) / 2;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (
                                      var i = 0;
                                      i < s.popularDestinations.length;
                                      i++
                                    ) ...[
                                      if (i > 0) SizedBox(width: gap),
                                      SizedBox(
                                        width: half,
                                        child: PopularDestinationCard(
                                          destination: s.popularDestinations[i],
                                          onTap: () => c.selectDestination(
                                            s.popularDestinations[i].id,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
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
                          const SizedBox(height: 28),
                          const Text(
                            'Ride with confidence',
                            style: TextStyle(
                              color: IntercityTokens.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.92,
                            children: [
                              for (final item in s.confidenceItems)
                                RideConfidenceCard(item: item),
                            ],
                          ),
                          SizedBox(height: 88 + bottomInset),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: IntercityTokens.background,
                border: Border(
                  top: BorderSide(color: IntercityTokens.border, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
                  child: FilledButton(
                    onPressed: c.searchRides,
                    style: FilledButton.styleFrom(
                      backgroundColor: IntercityTokens.searchButtonFill,
                      foregroundColor: IntercityTokens.searchButtonText,
                      elevation: 4,
                      shadowColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          IntercityTokens.radiusLg,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Search rides',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: IntercityTokens.headerButtonSize,
          height: IntercityTokens.headerButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: IntercityTokens.headerButtonFill,
            border: Border.all(color: IntercityTokens.border),
          ),
          child: Icon(
            icon,
            color: IntercityTokens.white,
            size: icon == Icons.chevron_left_rounded ? 28 : 22,
          ),
        ),
      ),
    );
  }
}
