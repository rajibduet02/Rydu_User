import 'package:flutter/material.dart';

import '../theme/intercity_tokens.dart';

class IntercityOfferCard extends StatelessWidget {
  const IntercityOfferCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IntercityTokens.radiusOffer),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IntercityTokens.radiusOffer),
            gradient: const LinearGradient(
              colors: [
                IntercityTokens.offerGradientStart,
                IntercityTokens.offerGradientEnd,
              ],
            ),
            border: Border.all(color: IntercityTokens.offerBorder),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: IntercityTokens.offerGreen,
                ),
                alignment: Alignment.center,
                child: const Text('🎉', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Get 30% OFF up to BDT 75 on your next ride!',
                  style: TextStyle(
                    color: IntercityTokens.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
