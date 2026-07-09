import 'package:flutter/material.dart';

import '../theme/rental_ride_tokens.dart';

class RentalPromotionBanner extends StatelessWidget {
  const RentalPromotionBanner({super.key, required this.promotionAmount});

  final double promotionAmount;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.035).clamp(13.0, 14.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RentalRideTokens.promoRadius),
        gradient: LinearGradient(
          colors: [
            RentalRideTokens.bolt.withValues(alpha: 0.22),
            RentalRideTokens.bolt.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: RentalRideTokens.bolt.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Text('🎉', style: TextStyle(fontSize: (w * 0.055).clamp(22.0, 26.0))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'BDT ${promotionAmount.toStringAsFixed(2)} promotion applied',
              style: TextStyle(
                color: RentalRideTokens.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
