import 'package:flutter/material.dart';

import '../../domain/entities/offer_entity.dart';
import '../theme/offers_tokens.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onBookNow,
    this.showDivider = true,
  });

  final OfferEntity offer;
  final VoidCallback onBookNow;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.05).clamp(18.0, 22.0);
    final iconSize = (w * 0.11).clamp(40.0, 48.0);
    final titleSize = (w * 0.042).clamp(15.0, 17.0);
    final metaSize = (w * 0.034).clamp(12.5, 14.0);
    final badgeSize = (w * 0.032).clamp(12.0, 13.0);

    final accent = offer.iconAccent == OfferIconAccent.gold
        ? OffersTokens.goldAccent
        : OffersTokens.redAccent;
    final iconBg = offer.iconAccent == OfferIconAccent.gold
        ? OffersTokens.goldIconBg
        : OffersTokens.redIconBg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.55)),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  color: accent,
                  size: iconSize * 0.42,
                ),
              ),
              SizedBox(width: (w * 0.04).clamp(14.0, 18.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: TextStyle(
                        color: OffersTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: (w * 0.02).clamp(6.0, 8.0)),
                    Text(
                      offer.subtitle,
                      style: TextStyle(
                        color: OffersTokens.muted,
                        fontSize: metaSize,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: (w * 0.012).clamp(4.0, 6.0)),
                    Text(
                      offer.expiryText,
                      style: TextStyle(
                        color: OffersTokens.muted,
                        fontSize: metaSize,
                        height: 1.35,
                      ),
                    ),
                    if (offer.badgeText != null) ...[
                      SizedBox(height: (w * 0.025).clamp(8.0, 12.0)),
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: OffersTokens.badgeGold,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'U',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              offer.badgeText!,
                              style: TextStyle(
                                color: OffersTokens.badgeGold,
                                fontSize: badgeSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: (w * 0.04).clamp(14.0, 18.0)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: OffersTokens.bookButtonBg,
                        borderRadius: BorderRadius.circular(999),
                        child: InkWell(
                          onTap: onBookNow,
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: (w * 0.05).clamp(18.0, 22.0),
                              vertical: (w * 0.028).clamp(10.0, 12.0),
                            ),
                            child: Text(
                              'Book now',
                              style: TextStyle(
                                color: OffersTokens.bookButtonText,
                                fontSize: metaSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: (w * 0.04).clamp(14.0, 18.0)),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: const Divider(
              height: 1,
              thickness: 1,
              color: OffersTokens.divider,
            ),
          ),
      ],
    );
  }
}
