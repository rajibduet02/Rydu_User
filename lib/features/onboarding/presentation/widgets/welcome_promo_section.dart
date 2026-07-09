import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/welcome_controller.dart';
import '../theme/welcome_tokens.dart';
import 'offer_card.dart';

class WelcomePromoSection extends ConsumerWidget {
  const WelcomePromoSection({super.key, required this.onSeeAllOffers});

  final VoidCallback onSeeAllOffers;

  static const _offers = ['25% OFF', '30% OFF', '20% OFF'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(welcomeControllerProvider).selectedOffer;
    final w = MediaQuery.sizeOf(context).width;
    final cardW = (w * 0.21).clamp(72.0, 88.0);
    final cardH = cardW * 1.2;
    final gap = (w * 0.03).clamp(10.0, 14.0);
    final headerSize = (w * 0.035).clamp(13.0, 15.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'For you',
                style: TextStyle(
                  color: WelcomeTokens.white,
                  fontSize: headerSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSeeAllOffers,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_forward,
                    color: WelcomeTokens.accent,
                    size: (w * 0.045).clamp(18.0, 22.0),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
        SizedBox(
          height: cardH,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _offers.length,
            separatorBuilder: (context, index) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              final label = _offers[index];
              return OfferCard(
                discountLabel: label,
                isSelected: selected == label,
                width: cardW,
                height: cardH,
                onTap: () => ref
                    .read(welcomeControllerProvider.notifier)
                    .selectOffer(label),
              );
            },
          ),
        ),
      ],
    );
  }
}
